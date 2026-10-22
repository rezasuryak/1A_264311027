CREATE TABLE pengguna (
  id_pengguna     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama_pengguna   VARCHAR(100) NOT NULL,
  nomor_pengenal  VARCHAR(30)  NOT NULL,                    -- NIM / NIP
  email           VARCHAR(100) NOT NULL,
  peran           ENUM('Mahasiswa','Dosen') NOT NULL,
  CONSTRAINT pk_pengguna PRIMARY KEY (id_pengguna),
  CONSTRAINT uq_pengguna_nomor UNIQUE (nomor_pengenal),
  CONSTRAINT uq_pengguna_email UNIQUE (email)
) ENGINE=InnoDB;

-- ---------- TABEL INDUK 2 : FASILITAS ----------
CREATE TABLE fasilitas (
  id_fasilitas    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama_fasilitas  VARCHAR(100) NOT NULL,
  kode_qr         VARCHAR(50)  NOT NULL,
  id_ruangan      INT UNSIGNED NOT NULL,   -- FK ke tabel ruangan (di luar 3 tabel soal)
  CONSTRAINT pk_fasilitas PRIMARY KEY (id_fasilitas),
  CONSTRAINT uq_fasilitas_qr UNIQUE (kode_qr)
) ENGINE=InnoDB;

-- ---------- TABEL TRANSAKSI : LAPORAN ----------
CREATE TABLE laporan (
  id_laporan           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pengguna          INT UNSIGNED NOT NULL,              -- FK ke induk 1
  id_fasilitas         INT UNSIGNED NOT NULL,              -- FK ke induk 2
  deskripsi_kerusakan  TEXT         NOT NULL,
  foto_bukti           VARCHAR(255) NULL,
  tanggal_lapor        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tingkat_urgensi      ENUM('Rendah','Sedang','Tinggi') NOT NULL DEFAULT 'Sedang',
  CONSTRAINT pk_laporan PRIMARY KEY (id_laporan),
  CONSTRAINT fk_laporan_pengguna FOREIGN KEY (id_pengguna)
    REFERENCES pengguna (id_pengguna)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_laporan_fasilitas FOREIGN KEY (id_fasilitas)
    REFERENCES fasilitas (id_fasilitas)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;
