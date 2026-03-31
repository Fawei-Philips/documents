# stop service
$services = @(
    "ImageManagementWindowsService",
    "PipelineNotifierService",
    "PipelineOrchestratorService",
    "IPF-AuditTrailService",
    "IPF-FastInMemoryRepositoryService",
    "IPF-LoggingService"
)
foreach ($svc in $services) {
    $serviceObj = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($serviceObj) {
        try { Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue } catch {}
        try { sc.exe delete $svc | Out-Null } catch {}
    }
}

# kill process
$processes = @(
    "ChMonitor.exe",
    "ChFundus.exe",
    "DirectorEXE.exe",
    "film.exe",
    "LogService.exe",
    "PatientDataService.exe",
    "PrintQueueManager.exe",
    "AlertsService.exe",
    "MonitoringProperties.exe",
    "SmartView.exe",
    "CsStoreSCP.exe",
    "PNMS.CT.Help.PDFPage.exe",
    "ICS.exe",
    "FrmDeletePageFile.exe",
    "ISTSLA.exe",
    "PNMS.MIPPP.Viewer.exe",
    "Analysis.exe",
    "PNMS.Report.UI.exe",
    "PNMS.MIF.StateFeedback.exe",
    "report20proxy.exe",
    "FpExe.exe",
    "PNMS.MIC.Win32COMService.exe",
    "GPUReconexe.exe",
    "idoseconverterexe.exe",
    "Viewer.exe",
    "Report.exe",
    "StatusBar.exe",
    "SearchProtocolHost.exe",
    "SCBridge.exe",
    "Philips.Pcc.CT.Console.IPaitentServiceConsole.exe",
    "IV.exe",
    "Philips.Pcc.CT.ServiceTool.AuditTrailServiceShell.exe",
    "Philips.Pcc.CT.Service.ProtocolEditorShell.exe",
    "Philips.Pcc.CT.CamProp.Desktop.exe",
    "Philips.Pcc.CT.Console.CanOpen.CanOpenSimulatorExe.exe",
    "Philips.Pcc.CT.Console.Foundation.exe",
    "Philips.PCC.SY.CloudHook.Viewer.exe",
    "Philips.NxGen.Services.FeatureManagement.WindowsService.exe",
    "Philips.CT.Host.ImageManagementWindowsService.exe",
    "Philips.CT.Host.PipelineNotifierServer.exe",
    "Philips.CT.Host.PipelineOrchestratorWindowsService.exe",
    "Philips.CT.Host.SuggestionService.exe",
    "Philips.IAP.NotificationServiceApplication.exe",
    "Philips.IAP.ProxyServiceApplication.exe",
    "Philips.NxGen.Serviceability.ConfigurationService.exe",
    "Philips.NxGen.Services.LicenseManagement.Hosting.exe",
    "Philips.NxGen.Services.LicenseSwitchManagement.Service.exe",
    "Philips.PCC.CT.Service.SDCApp.SDCService.exe",
    "Philips.Platform.LogService.exe",
    "Philips.Platform.ServiceHost.exe",
    "Philips.RemoteTools.CommonWebServerHost.exe",
    "Philips.RemoteTools.RemoteServiceHostApplication.exe",
    "Philips.Service.RemoteTools.RemoteServiceController.exe",
    "Philips.ServicePlatform.ServiceManager.ServiceHostApplication.exe",
    "Philips.ServicePlatform.ServiceManager.ServiceHostController.exe",
    "Philips.CT.Host.PipelineProcess.exe",
    "GantryPcHost.exe",
    "Philips.ServiceTools.RSDI.MainEngineService.exe",
    "Philips.ServiceTools.RSDI.SubEngineService.exe",
    "Philips.ServiceTools.RSDI.SuSdService.exe",
    "Philips.Pcc.CT.Service.ProcessMonitor.exe"
)
foreach ($proc in $processes) {
    try { Stop-Process -Name ($proc -replace ".exe$","") -Force -ErrorAction SilentlyContinue } catch {}
}

if (Test-Path "C:\opt") {
    Remove-Item "C:\opt" -Recurse -Force
    Write-Host "Deleted C:\opt"
} else {
    Write-Host "C:\opt does not exist."
}

if (Test-Path "D:\PCC") {
    Remove-Item "D:\PCC" -Recurse -Force
    Write-Host "Deleted D:\PCC"
} else {
    Write-Host "D:\PCC does not exist."
}
