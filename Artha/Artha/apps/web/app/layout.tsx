import type { Metadata } from "next";
import "./style.css";
export const metadata: Metadata = { title: "Artha", description: "Your personal digital workspace" };
export default function RootLayout({children}:{children:React.ReactNode}) { return <html lang="en"><body>{children}</body></html>; }
