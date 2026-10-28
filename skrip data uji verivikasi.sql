INSERT INTO gedung (nama_gedung, lokasi) VALUES ('Gedung A', 'Kampus Utara');
INSERT INTO ruangan (nama_ruangan, lantai, id_gedung) VALUES ('Lab Komputer 1', 2, 1);
INSERT INTO fasilitas (nama_fasilitas, kode_qr, id_ruangan) VALUES ('AC', 'QR-001', 1);

INSERT INTO pengguna (nama_pengguna, nomor_pengenal, peran) VALUES
  ('Budi Santoso', '264311001', 'Mahasiswa'),
  ('Dr. Siti Aminah', '198001012005012001', 'Dosen');
INSERT INTO email_pengguna VALUES (1, 'budi@kampus.ac.id'), (2, 'siti@kampus.ac.id');
INSERT INTO mahasiswa (id_pengguna, prodi, angkatan) VALUES (1, 'TRPL', 2026);
INSERT INTO dosen (id_pengguna, jurusan) VALUES (2, 'Teknik');

INSERT INTO teknisi (nama_teknisi, spesialis) VALUES ('Pak Andi', 'Elektrikal');
INSERT INTO pemasok (nama_pemasok, kontak) VALUES ('CV Sinar Dingin', '0812-1111');
INSERT INTO suku_cadang (nama_suku_cadang, satuan, stok, stok_minimum, harga_satuan, id_pemasok)
  VALUES ('Freon R32', 'tabung', 10, 3, 150000, 1);

INSERT INTO laporan (deskripsi_kerusakan, tingkat_urgensi, id_pengguna, id_fasilitas)
  VALUES ('AC tidak dingin', 'Tinggi', 1, 1);
INSERT INTO perbaikan (id_laporan, id_perbaikan, tanggal_mulai, biaya_jasa, status_penanganan, id_teknisi)
  VALUES (1, 1, NOW(), 50000, 'Selesai', 1);
INSERT INTO pemakaian_suku_cadang VALUES (1, 1, 1, 1, 150000);
INSERT INTO penilaian (id_laporan, rating, komentar) VALUES (1, 5, 'Cepat dan rapi');

-- Total biaya per laporan (jasa + suku cadang)
SELECT p.id_laporan, p.id_perbaikan,
       p.biaya_jasa + COALESCE(SUM(m.jumlah * m.harga_saat_pakai), 0) AS total_biaya
FROM perbaikan p
LEFT JOIN pemakaian_suku_cadang m
       ON m.id_laporan = p.id_laporan AND m.id_perbaikan = p.id_perbaikan
GROUP BY p.id_laporan, p.id_perbaikan, p.biaya_jasa;

-- Suku cadang yang perlu dipesan ulang
SELECT nama_suku_cadang, stok, stok_minimum FROM suku_cadang WHERE stok <= stok_minimum;
