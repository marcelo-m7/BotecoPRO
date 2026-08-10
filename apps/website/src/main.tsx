import { createRoot } from "react-dom/client";
import App from "./App.tsx";
import "./globals.css";
import './i18n'; // Importar a configuração do i18n
import { I18nextProvider } from 'react-i18next';
import i18n from './i18n';
import { ClerkProvider } from '@clerk/clerk-react';
import { HelmetProvider } from 'react-helmet-async'; // Importar HelmetProvider
import { ThemeProvider } from './components/ThemeProvider.tsx'; // Importar ThemeProvider

// Obtenha a chave pública do Clerk do ambiente
const PUBLISHABLE_KEY = import.meta.env.VITE_CLERK_PUBLISHABLE_KEY;

if (!PUBLISHABLE_KEY) {
  throw new Error("Missing Publishable Key from Clerk. Please add VITE_CLERK_PUBLISHABLE_KEY to your .env file.");
}

createRoot(document.getElementById("root")!).render(
  <ClerkProvider publishableKey={PUBLISHABLE_KEY}>
    <I18nextProvider i18n={i18n}>
      <HelmetProvider>
        <ThemeProvider defaultTheme="system" storageKey="vite-ui-theme"> {/* Envolver o App com ThemeProvider */}
          <App />
        </ThemeProvider>
      </HelmetProvider>
    </I18nextProvider>
  </ClerkProvider>
);