"use client";

import * as React from "react";
import { Slot } from "@radix-ui/react-slot";

import { cn } from "@/lib/utils";
import { DepthLevel, getDepthClassName } from "./depth-tokens";

export type DepthSurfaceProps = React.HTMLAttributes<HTMLDivElement> & {
  depth?: DepthLevel;
  asChild?: boolean;
  interactive?: boolean;
};

export const DepthSurface = React.forwardRef<HTMLDivElement, DepthSurfaceProps>(
  ({ depth = 100, asChild, interactive, className, children, ...props }, ref) => {
    const Component = asChild ? Slot : "div";

    return (
      <Component
        ref={ref}
        data-depth={depth}
        className={cn(
          "relative depth-transition border border-transparent",
          getDepthClassName(depth),
          interactive && "hover:-translate-y-1 focus-visible:-translate-y-1",
          interactive && "active:-translate-y-0.5",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-boteco-mustard-500 focus-visible:ring-offset-background",
          className,
        )}
        {...props}
      >
        {children}
      </Component>
    );
  },
);
DepthSurface.displayName = "DepthSurface";

export type DepthStackProps = Omit<DepthSurfaceProps, "className"> & {
  className?: string;
  containerClassName?: string;
  layers?: number;
  layerDepth?: DepthLevel;
  layerOffset?: number;
};

export const DepthStack: React.FC<DepthStackProps> = ({
  depth = 200,
  layerDepth,
  layers = 3,
  layerOffset = 6,
  containerClassName,
  className,
  children,
  ...surfaceProps
}) => {
  const visualLayerDepth = layerDepth ?? (depth === 300 ? 200 : 100);
  const layerCount = Math.max(1, layers);

  return (
    <div
      data-depth-stack={depth}
      className={cn("relative isolate", containerClassName)}
    >
      {Array.from({ length: layerCount - 1 }).map((_, index) => (
        <div
          key={`depth-layer-${index}`}
          aria-hidden
          data-depth-layer={index + 1}
          className={cn(
            "pointer-events-none absolute inset-0 rounded-[inherit] opacity-70 border border-transparent",
            getDepthClassName(visualLayerDepth),
          )}
          style={{
            transform: `translate(${(index + 1) * layerOffset}px, ${(index + 1) * layerOffset}px)`,
            zIndex: -index - 1,
          }}
        />
      ))}
      <DepthSurface
        depth={depth}
        className={cn("relative z-10", className)}
        {...surfaceProps}
      >
        {children}
      </DepthSurface>
    </div>
  );
};

export type DepthSpotlightProps = DepthSurfaceProps & {
  spotlightRadius?: string;
  spotlightOpacity?: number;
};

export const DepthSpotlight = React.forwardRef<HTMLDivElement, DepthSpotlightProps>(
  (
    {
      depth = 200,
      spotlightRadius = "280px",
      spotlightOpacity = 0.22,
      interactive = true,
      className,
      style,
      children,
      ...props
    },
    ref,
  ) => {
    const [coords, setCoords] = React.useState({ x: "50%", y: "50%" });

    const handlePointerMove = React.useCallback<React.PointerEventHandler<HTMLDivElement>>(
      (event) => {
        const bounds = event.currentTarget.getBoundingClientRect();
        const x = ((event.clientX - bounds.left) / bounds.width) * 100;
        const y = ((event.clientY - bounds.top) / bounds.height) * 100;
        setCoords({ x: `${x.toFixed(1)}%`, y: `${y.toFixed(1)}%` });
      },
      [],
    );

    const handlePointerLeave = React.useCallback(() => {
      setCoords({ x: "50%", y: "50%" });
    }, []);

    return (
      <DepthSurface
        ref={ref}
        depth={depth}
        interactive={interactive}
        className={cn("overflow-hidden", className)}
        style={{
          ...style,
          backgroundImage: `radial-gradient(${spotlightRadius} at ${coords.x} ${coords.y}, color-mix(in srgb, var(--depth-spotlight-color) ${Math.round(spotlightOpacity * 100)}%, transparent), transparent)`,
        }}
        onPointerMove={handlePointerMove}
        onPointerLeave={handlePointerLeave}
        {...props}
      >
        <div className="relative z-10">{children}</div>
      </DepthSurface>
    );
  },
);
DepthSpotlight.displayName = "DepthSpotlight";

export default DepthSurface;
