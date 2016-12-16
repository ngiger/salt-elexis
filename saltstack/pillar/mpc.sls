# Konfiguration Mediport Communicator von MediData.ch
# ElexisPraxisDemo
mpc:
  # zip_path: /opt/downloads/MediPortCommunicator-Linux_64.zip
  zip_path: http://download.elexis.info/MPC/19.0/Linux_64.zip
  hash: sha256=b89d3c87b63addb628c741f39ff64487bc75415c3f03ad41a22fb3974d515e23
  bin_name: 'MPCommunicator V1.19.0.0_x64.bin'
  install_path: /usr/local/mediport/program
  data_path: /usr/local/mediport/data
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
      - type: tp # Tiers Payant
        language: D
      - type: tg # Tiers_Garant_Manuell
        language: D
