import MainScreen from "./components/MainScreen";
import { HumanSecurityManager } from "@/src/utils/HumanSecurityManager";

// Choose your start method according to your implementation.
// If you are using react webView for a site protected by HUMAN configure the startHybrid.
HumanSecurityManager.start();
// HumanSecurityManager.startHybrid();

export default function Index() {
    return <MainScreen />;
}
