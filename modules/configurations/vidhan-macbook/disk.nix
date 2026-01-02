{
  configurations.vidhan-macbook.module = {
    disko.devices.disk.main = {
      device = "/dev/disk/by-id/nvme-APPLE_SSD_AP0256Q_0ba012e404080419";

      content.partitions = {
        iBootSystemContainer.uuid = "62132ea7-731c-44eb-848a-80a899f51311";
        Container.uuid = "18fa4f40-f0b2-407f-9eea-a1491cefeaa4";
        NixOSContainer.uuid = "4238759e-8d52-4fd7-a67f-c1476fce03f9";
        ESP.uuid = "ff9579f2-e598-4e95-b8be-91f66eaba3a4";
        RecoveryOSContainer.uuid = "37b1fd46-dc1b-4342-887c-f533d6ca1de2";
      };
    };
  };
}
