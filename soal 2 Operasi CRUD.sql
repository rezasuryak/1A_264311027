INSERT INTO pengguna (id_pengguna, nama_pengguna, nomor_pengenal, email, peran) VALUES
  (1, 'Budi Santoso',    '264311001',          'budi@kampus.ac.id',  'Mahasiswa'),
  (2, 'Rina Wulandari',  '264311002',          'rina@kampus.ac.id',  'Mahasiswa'),
  (3, 'Dr. Siti Aminah', '198001012005012001', 'siti@kampus.ac.id',  'Dosen');

INSERT INTO fasilitas (id_fasilitas, nama_fasilitas, kode_qr, id_ruangan) VALUES
  (1, 'AC',        'QR-001', 1),
  (2, 'Proyektor', 'QR-002', 2),
  (3, 'Komputer',  'QR-003', 3);

INSERT INTO laporan (id_laporan, id_pengguna, id_fasilitas, deskripsi_kerusakan, tanggal_lapor, tingkat_urgensi) VALUES
  (1, 1, 1, 'AC tidak dingin',            '2026-10-12 08:00:00', 'Tinggi'),
  (2, 2, 2, 'Proyektor tidak menyala',    '2026-10-13 09:30:00', 'Sedang'),
  (3, 3, 3, 'Komputer tidak bisa booting','2026-10-14 10:15:00', 'Rendah');

SELECT * FROM pengguna;

UPDATE laporan
   SET tingkat_urgensi = 'Tinggi'
 WHERE id_laporan = 2;

SELECT id_laporan, deskripsi_kerusakan, tingkat_urgensi FROM laporan WHERE id_laporan = 2;

DELETE FROM laporan
 WHERE id_laporan = 3;

SELECT * FROM laporan;
