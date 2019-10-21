# Disable Windows update notifications
# Helpful on Termial Services Servers when we don't want these notifications to appear to end users.

Disable-ScheduledTask -TaskPath \Microsoft\Windows\UpdateOrchestrator\ -TaskName USO_UxBroker_Display
Disable-ScheduledTask -TaskPath \Microsoft\Windows\UpdateOrchestrator\ -TaskName MusUx_UpdateInterval