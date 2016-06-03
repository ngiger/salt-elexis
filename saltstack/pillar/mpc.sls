# Konfiguration Mediport Communicator von MediData.ch
# ElexisPraxisDemo
mpc:
  install_path: /home/pbt/data/shared/medidata
  zip_path: /opt/downloads/MediPortCommunicator-Linux_64.zip
  bin_name: MPCommunicator_V1.16.0.0.bin
  #    Produktiver Server: mpw1.medidata.ch
  #    Test Server       : mpw0.medidata.ch
  mpc_server:   'mpw0.medidata.ch'
  trust_center_ean: 7601001123456
  sender_ean: 7601231123456
  keystore:   salt://files/EAN7601231123456_mpg.keystore
  dn_attributes: 'ou=Produktiv,ou=Dr med Elexis,ou=Leistungserbringer,o=medidata.ch'
  mandants:
    - name: arzt
      ean: 7601231123456
      invoice_types:
      - type: tg # Tiers_Garant_Manuell
        language: D
      - type: tp # Tiers Payant
        language: D
