from __future__ import annotations

import os
import shlex
import subprocess
import sys
import time
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Mapping, Sequence

from .privacy import redact_command


@dataclass(frozen=True)
class CommandResult:
    command: list[str]
    cwd: str
    started_at: str
    duration_seconds: float
    return_code: int
    stdout: str
    stderr: str

    @property
    def ok(self) -> bool:
        return self.return_code == 0

    def to_dict(self, include_output: bool = True) -> dict[str, object]:
        result = asdict(self)
        if not include_output:
            result.pop("stdout", None)
            result.pop("stderr", None)
        return result


class CommandFailed(RuntimeError):
    def __init__(self, result: CommandResult):
        self.result = result
        super().__init__(f"Comando falhou ({result.return_code}): {' '.join(result.command)}")


class Runner:
    def __init__(self, verbose: bool = False):
        self.verbose = verbose

    def run(
        self,
        command: Sequence[str],
        *,
        cwd: Path,
        env: Mapping[str, str] | None = None,
        timeout: float | None = None,
        check: bool = False,
        stream: bool = True,
    ) -> CommandResult:
        safe_command = redact_command(str(item) for item in command)
        printable = " ".join(shlex.quote(item) for item in safe_command)
        print(f"[RUN ] {printable}")
        if self.verbose:
            print(f"[INFO] cwd={cwd}")
        started_epoch = time.time()
        started = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime(started_epoch))
        try:
            completed = subprocess.run(
                [str(item) for item in command],
                cwd=cwd,
                env=dict(os.environ if env is None else env),
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=timeout,
                check=False,
            )
            return_code = completed.returncode
            stdout = completed.stdout
            stderr = completed.stderr
        except subprocess.TimeoutExpired as error:
            return_code = 124
            stdout = error.stdout or ""
            stderr = (error.stderr or "") + f"\nTimeout após {timeout}s."
        duration = round(time.time() - started_epoch, 3)
        result = CommandResult(
            command=safe_command,
            cwd=str(cwd),
            started_at=started,
            duration_seconds=duration,
            return_code=return_code,
            stdout=stdout,
            stderr=stderr,
        )
        if stream or (not result.ok):
            if stdout:
                print(stdout, end="" if stdout.endswith("\n") else "\n")
            if stderr:
                print(stderr, file=sys.stderr, end="" if stderr.endswith("\n") else "\n")
        label = "PASS" if result.ok else "FAIL"
        print(f"[{label}] exit={result.return_code} duration={result.duration_seconds:.3f}s")
        if check and not result.ok:
            raise CommandFailed(result)
        return result
