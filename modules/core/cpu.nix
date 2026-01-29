{ ... }:
{

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
    cpufreq.min = 800000;
  };

  boot.kernelModules = [ "amd_pstate" ]; # load the modern driver
  boot.kernelParams = [ "amd_pstate=active" ]; # use active mode (dynamic scaling)

}
