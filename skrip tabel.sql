CREATE DATABASE IF NOT EXISTS sipkf
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sipkf;

-- 1. Master lokasi
CREATE TABLE gedung (
  id_gedung    INT AUTO_INCREMENT PRIMARY KEY,
  nama_gedung  VARCHAR(100) NOT NULL UNIQUE,
  lokasi       VARCHAR(150)
) ENGINE=InnoDB;

CREATE TABLE ruangan (
  id_ruangan    INT AUTO_INCREMENT PRIMARY KEY,
  nama_ruangan  VARCHAR(100) NOT NULL,
  lantai        INT NOT NULL DEFAULT 1,
  id_gedung     INT NOT NULL,
  CONSTRAINT uq_ruangan UNIQUE (id_gedung, nama_ruangan),
  CONSTRAINT fk_ruangan_gedung FOREIGN KEY (id_gedung)
    REFERENCES gedung(id_gedung) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE fasilitas (
  id_fasilitas    INT AUTO_INCREMENT PRIMARY KEY,
  nama_fasilitas  VARCHAR(100) NOT NULL,
  kode_qr         VARCHAR(50) NOT NULL UNIQUE,
  id_ruangan      INT NOT NULL,
  CONSTRAINT fk_fasilitas_ruangan FOREIGN KEY (id_ruangan)
    REFERENCES ruangan(id_ruangan) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 2. Pengguna dan spesialisasi (disjoint dipaksa lewat FK komposit)
CREATE TABLE pengguna (
  id_pengguna     INT AUTO_INCREMENT PRIMARY KEY,
  nama_pengguna   VARCHAR(100) NOT NULL,
  nomor_pengenal  VARCHAR(30)  NOT NULL UNIQUE,
  peran           ENUM('Mahasiswa','Dosen') NOT NULL,
  CONSTRAINT uq_pengguna_peran UNIQUE (id_pengguna, peran)
) ENGINE=InnoDB;

CREATE TABLE email_pengguna (
  id_pengguna  INT NOT NULL,
  email        VARCHAR(100) NOT NULL UNIQUE,
  PRIMARY KEY (id_pengguna, email),
  CONSTRAINT fk_email_pengguna FOREIGN KEY (id_pengguna)
    REFERENCES pengguna(id_pengguna) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE mahasiswa (
  id_pengguna  INT PRIMARY KEY,
  peran        ENUM('Mahasiswa','Dosen') NOT NULL DEFAULT 'Mahasiswa',
  prodi        VARCHAR(100),
  angkatan     YEAR,
  CONSTRAINT ck_mahasiswa_peran CHECK (peran = 'Mahasiswa'),
  CONSTRAINT fk_mahasiswa_pengguna FOREIGN KEY (id_pengguna, peran)
    REFERENCES pengguna(id_pengguna, peran) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE dosen (
  id_pengguna  INT PRIMARY KEY,
  peran        ENUM('Mahasiswa','Dosen') NOT NULL DEFAULT 'Dosen',
  jurusan      VARCHAR(100),
  CONSTRAINT ck_dosen_peran CHECK (peran = 'Dosen'),
  CONSTRAINT fk_dosen_pengguna FOREIGN KEY (id_pengguna, peran)
    REFERENCES pengguna(id_pengguna, peran) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. Teknisi dan pemasok
CREATE TABLE teknisi (
  id_teknisi    INT AUTO_INCREMENT PRIMARY KEY,
  nama_teknisi  VARCHAR(100) NOT NULL,
  spesialis     VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE pemasok (
  id_pemasok    INT AUTO_INCREMENT PRIMARY KEY,
  nama_pemasok  VARCHAR(100) NOT NULL UNIQUE,
  kontak        VARCHAR(30),
  alamat        VARCHAR(200)
) ENGINE=InnoDB;

CREATE TABLE suku_cadang (
  id_suku_cadang    INT AUTO_INCREMENT PRIMARY KEY,
  nama_suku_cadang  VARCHAR(100) NOT NULL,
  satuan            VARCHAR(20)  NOT NULL DEFAULT 'pcs',
  stok              INT NOT NULL DEFAULT 0,
  stok_minimum      INT NOT NULL DEFAULT 0,
  harga_satuan      DECIMAL(12,2) NOT NULL,
  id_pemasok        INT NOT NULL,
  CONSTRAINT ck_sc_stok  CHECK (stok >= 0 AND stok_minimum >= 0),
  CONSTRAINT ck_sc_harga CHECK (harga_satuan >= 0),
  CONSTRAINT fk_sc_pemasok FOREIGN KEY (id_pemasok)
    REFERENCES pemasok(id_pemasok) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. Transaksi
CREATE TABLE laporan (
  id_laporan           INT AUTO_INCREMENT PRIMARY KEY,
  deskripsi_kerusakan  TEXT NOT NULL,
  foto_bukti           VARCHAR(255),
  tanggal_lapor        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tingkat_urgensi      ENUM('Rendah','Sedang','Tinggi') NOT NULL DEFAULT 'Sedang',
  id_pengguna          INT NOT NULL,
  id_fasilitas         INT NOT NULL,
  CONSTRAINT fk_laporan_pengguna FOREIGN KEY (id_pengguna)
    REFERENCES pengguna(id_pengguna) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_laporan_fasilitas FOREIGN KEY (id_fasilitas)
    REFERENCES fasilitas(id_fasilitas) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE perbaikan (
  id_laporan         INT NOT NULL,
  id_perbaikan       INT NOT NULL,
  tanggal_mulai      DATETIME,
  tanggal_selesai    DATETIME,
  biaya_jasa         DECIMAL(12,2) NOT NULL DEFAULT 0,
  status_penanganan  ENUM('Menunggu','Diproses','Selesai','Gagal') NOT NULL DEFAULT 'Menunggu',
  id_teknisi         INT NOT NULL,
  PRIMARY KEY (id_laporan, id_perbaikan),
  CONSTRAINT ck_perbaikan_tgl CHECK (tanggal_selesai IS NULL OR tanggal_selesai >= tanggal_mulai),
  CONSTRAINT ck_perbaikan_biaya CHECK (biaya_jasa >= 0),
  CONSTRAINT fk_perbaikan_laporan FOREIGN KEY (id_laporan)
    REFERENCES laporan(id_laporan) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_perbaikan_teknisi FOREIGN KEY (id_teknisi)
    REFERENCES teknisi(id_teknisi) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE pemakaian_suku_cadang (
  id_laporan        INT NOT NULL,
  id_perbaikan      INT NOT NULL,
  id_suku_cadang    INT NOT NULL,
  jumlah            INT NOT NULL,
  harga_saat_pakai  DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (id_laporan, id_perbaikan, id_suku_cadang),
  CONSTRAINT ck_pemakaian_jumlah CHECK (jumlah > 0),
  CONSTRAINT ck_pemakaian_harga  CHECK (harga_saat_pakai >= 0),
  CONSTRAINT fk_pemakaian_perbaikan FOREIGN KEY (id_laporan, id_perbaikan)
    REFERENCES perbaikan(id_laporan, id_perbaikan) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_pemakaian_sc FOREIGN KEY (id_suku_cadang)
    REFERENCES suku_cadang(id_suku_cadang) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE penilaian (
  id_penilaian       INT AUTO_INCREMENT PRIMARY KEY,
  id_laporan         INT NOT NULL UNIQUE,
  rating             TINYINT NOT NULL,
  komentar           VARCHAR(300),
  tanggal_penilaian  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ck_penilaian_rating CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT fk_penilaian_laporan FOREIGN KEY (id_laporan)
    REFERENCES laporan(id_laporan) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. Index untuk kolom pencarian
CREATE INDEX idx_fasilitas_nama       ON fasilitas(nama_fasilitas);
CREATE INDEX idx_laporan_tanggal      ON laporan(tanggal_lapor);
CREATE INDEX idx_laporan_urgensi      ON laporan(tingkat_urgensi);
CREATE INDEX idx_perbaikan_status     ON perbaikan(status_penanganan);
CREATE INDEX idx_suku_cadang_nama     ON suku_cadang(nama_suku_cadang);
