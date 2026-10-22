SELECT p.nama_pengguna, COUNT(l.id_laporan) AS jumlah_laporan
FROM laporan l
JOIN pengguna p ON l.id_pengguna = p.id_pengguna
WHERE l.tanggal_lapor >= '2026-10-01'
GROUP BY p.id_pengguna, p.nama_pengguna;
