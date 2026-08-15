# agenix recipients manifest
#
# Declares which public keys may decrypt each *.age secret. Host keys decrypt
# at activation on that machine; admin (user) keys allow editing via `agenix -e`.
#
# Re-key after editing this file:  agenix -r
let
  # Host SSH public keys (/etc/ssh/ssh_host_ed25519_key.pub) — runtime decrypt
  xenomorph = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC3f6BUYzSh8X+nMGxlpQIdF/ut+vxTl+W22WFWiVT5e root@nixos";
  neomorph = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEDFfzno7jths4fR8U8OkJpdQTFCqqF5kyf771ddn5XE root@neomorph";

  # Admin keys — for editing secrets
  marcoXenomorph = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEP/4eQAgvIQIbEGkNMZ8ObatVPB4vCy0TypeCkQ4RymgDLZdZLd0T1jS4TliOHr5cOteIrZdJexQCYoenyxlpPtT97+XIQgPPQ54vsHpdQMW08rEraJAFs5w0KDwpXAA2tVMpkVyFw6blAKyI5NBc5SRoD5x3NV+TESh3O7trBgNNLb3pB7jTvbsKuYhAFIOvhUrX9XyeaD5kr9KkL86FHFnSCwFV42DwXRHGrJ4RBilpY2YDXl/BN9pDOXACsM7h0t7+7kTVjQ7c42hbe41ktgfjJWwjOKTR848/CFOYgh/Iawlw7CP2/4ZMDBrTBI+fM0g7tI0rd7U2puO6BkypewUblxOx1qF7o0wtS/a327A20TmsQdbheolwVmSR1jZP6+WUey7BRd5IiOrSuSVDI2WJl6b/g2ETCBrV7Xi+SiFuyeAD8FQZFFkCDTMm4Xmob0hn4uWy0Mt6J1S8YAU5ESSl2N9WszTNHfD1eisvTFjo6RcWlSsnZXPuK+0J/3BB/Y8VgEOL/FoftyrWpXSQ7zepbAM+yyDs4DzUjBOC0g7Tpy3M5bj/a1sdhOc42+u86zT0KRr44fmxQBNZpDuAXNJ8JNQ7gdJ91QPPK13Avj5zLDeWb7p1GmFmcNeVjSdcRIIvOhZqC9HJqFuJMRSJrSmrG3KDX/paoFb4xQYnxw== marco@xenomorph";
  marcoNeomorph = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+rc4Jlr0cldJsLKJO/GWM5781XgK6yutjuE+MP052nEnSh65sjuRhK6AM1yqil9gLFRmZVkhfMPb4sw2syUfH/M7ZGo4xeTaswNdfOmhEzYjrYZ6rpXJdro8YgUeBfsKi+4NFWIBcS32xSHq3VejJe+b6EQm6CnMA2TFcvQ/7cCJvt35WGk/vgzJmDrFCuffUjezzpvEQPxOZ/o/0pl01eYyjuuWbCpuGzTZTrf61uhzzZP99Er+o2gUPStVvmJRBkhLoroxOYsOj9dhRomSwz11spbd106N37Cklxo5CmA7gtumErKY/WjRnVe8Pibjwp06jqSzfjs1RHe0llChoe+7BrI0QTWrfTuBBxcBOPy0VctWHf1zO/UefYwdk20B/kh8TyCRAgunmRAvIAP6zm8v2D93J646OEhVh6jzWGbQB0k4ITHHHLSOQboK6RiaVDiZaRbuj7dhDbMGVwD/WrZ9szawnYZP4FVz/Lid2uHDZstEak0C12686Qi/bkpFhdAnZ2bX0/l3//qyWcAjGbXjCMjy/aSSM/nyulgKN6XylBjxrNG0QdwwmGm1uBo1Ff+YF/YD7TfBSsQ8LuPvxhy6c4mZhCaCCS9KR5APVMhL0LJjOlYTqRwtoxfdxlKSVHTBbYLrOJT6cIyM+ia5EneMZWakzZAbdrI3Fi2VsIQ== marco@neomorph";

  # Break-glass offline key — private half stored in 1Password, for disaster
  # recovery / re-keying independent of any machine. See DR notes.
  breakGlass = "age1y86ee5nz4yjtfd8t76c9ake03cc0r93a4lu8v6e2jg86t86jd3rswf57tf";

  admins = [
    marcoXenomorph
    marcoNeomorph
    breakGlass
  ];
in
# Per-host secrets: decryptable by that host only, plus the admin keys
{
  "borg-passphrase-xenomorph.age".publicKeys = [ xenomorph ] ++ admins;
  "borg-passphrase-neomorph.age".publicKeys = [ neomorph ] ++ admins;
  "healthchecks-xenomorph.age".publicKeys = [ xenomorph ] ++ admins;
  "healthchecks-neomorph.age".publicKeys = [ neomorph ] ++ admins;
  "healthchecks-check-xenomorph.age".publicKeys = [ xenomorph ] ++ admins;
}
