# Dokumentasi Logika Perhitungan HPP

> Versi: 1.1 — dibuat untuk review & koreksi  
> Last updated: 7 Maret 2026

---

## 1. Konsep Dasar

Semua perhitungan HPP berbasis **biaya total BULANAN**, kemudian dibagi dengan **total produksi per bulan**.  
Ini berlaku seragam untuk semua jenis produksi (harian, batch, bulanan).

```
HPP per Unit = Total Biaya Bulanan / Total Produksi per Bulan
```

---

## 2. Setting Produksi

### 2a. Produksi Harian (`JenisProduksi.harian`)

| Field Input           | Keterangan                          |
|-----------------------|-------------------------------------|
| Produksi/Hari         | Jumlah unit yang diproduksi per hari |
| Hari Kerja/Bulan      | Berapa hari produksi dalam sebulan  |

```
Total Produksi/Bulan = Produksi/Hari × Hari Kerja/Bulan

Contoh: 10 unit/hari × 25 hari = 250 unit/bulan
```

---

### 2b. Produksi Batch (`JenisProduksi.batch`)

| Field Input            | Keterangan                             |
|------------------------|----------------------------------------|
| Produksi/Batch         | Jumlah unit yang dihasilkan per batch  |
| Frekuensi Batch/Bulan  | Berapa kali produksi batch per bulan   |

> **Hari Kerja tidak digunakan** pada mode batch karena produksi tidak berbasis harian.  
> `hariKerjaBulan` diset otomatis ke 25 (default) tapi tidak mempengaruhi perhitungan.

```
Total Produksi/Bulan = Produksi/Batch × Frekuensi Batch/Bulan

Contoh: 100 unit/batch × 4 batch/bulan = 400 unit/bulan
```

---

### 2c. Produksi Bulanan (`JenisProduksi.bulanan`) & Custom

```
Total Produksi/Bulan = Jumlah Produksi/Hari × Hari Kerja/Bulan
(field input sama seperti harian, namun interpretasinya sebagai target bulanan)
```

---

## 3. Komponen Biaya — Konversi ke Bulanan

Setiap komponen biaya dikonversi ke nilai **bulanan** sebelum dijumlahkan.

| Periode Komponen | Rumus Konversi ke Bulanan              | Contoh Input | Hasil Bulanan       |
|------------------|----------------------------------------|--------------|---------------------|
| **Harian**       | `Nilai × Hari Kerja/Bulan`             | Rp 50.000    | Rp 50.000 × 25 = Rp 1.250.000 |
| **Per Batch**    | `Nilai × Frekuensi Batch/Bulan`        | Rp 200.000   | Rp 200.000 × 4 = Rp 800.000 |
| **Mingguan**     | `Nilai × (52 / 12)` ≈ `Nilai × 4,333` | Rp 200.000   | Rp 200.000 × 4,333 = Rp 866.667 |
| **Bulanan**      | `Nilai` (tidak dikonversi)             | Rp 500.000   | Rp 500.000 |

> **Catatan:** Opsi **Per Batch** hanya bermakna saat mode produksi batch. Gunakan ini untuk biaya bahan baku dan biaya langsung yang terjadi setiap kali batch produksi dijalankan. Harian/Mingguan/Bulanan tetap berlaku untuk overhead seperti listrik, sewa, dll.

```
Total Biaya Bulanan = Σ (Nilai Bulanan setiap komponen)
```

---

## 4. Perhitungan HPP

```
Total Biaya Bulanan = Σ semua komponen biaya yang sudah dikonversi ke bulanan

HPP per Unit = Total Biaya Bulanan / Total Produksi per Bulan

Harga Jual per Unit = HPP per Unit × (1 + Profit Margin / 100)

Profit per Unit = Harga Jual per Unit − HPP per Unit
```

### Contoh Lengkap (Produksi Harian)

- Bahan Baku: Rp 50.000/hari → bulanan = Rp 50.000 × 25 = **Rp 1.250.000**
- Tenaga Kerja: Rp 100.000/hari → bulanan = Rp 100.000 × 25 = **Rp 2.500.000**
- Overhead: Rp 300.000/bulan → bulanan = **Rp 300.000**
- **Total Biaya Bulanan = Rp 4.050.000**
- Produksi: 10 unit/hari × 25 hari = **250 unit/bulan**
- **HPP/unit = Rp 4.050.000 / 250 = Rp 16.200**
- Profit Margin 30%: Harga Jual = Rp 16.200 × 1,30 = **Rp 21.060**

---

### Contoh Lengkap (Produksi Batch)

- Bahan Baku: Rp 200.000 **Per Batch** × 4 batch/bulan = **Rp 800.000**
- Tenaga Kerja: Rp 150.000 **Per Batch** × 4 batch/bulan = **Rp 600.000**
- Overhead (listrik, sewa): Rp 500.000 **Bulanan** → **Rp 500.000**
- **Total Biaya Bulanan = Rp 1.900.000**
- Produksi: 100 unit/batch × 4 batch/bulan = **400 unit/bulan**
- **HPP/unit = Rp 1.900.000 / 400 = Rp 4.750**
- Profit Margin 30%: Harga Jual = Rp 4.750 × 1,30 = **Rp 6.175**

---

## 5. Profit Summary

| Metrik                  | Rumus                                         |
|-------------------------|-----------------------------------------------|
| Profit per Unit         | `Harga Jual − HPP`                            |
| Total Profit/Siklus     | Harian: `Profit/unit × produksi/hari`         |
|                         | Batch: `Profit/unit × produksi/batch`         |
|                         | Bulanan: `Profit/unit × total produksi/bulan` |
| Total Profit Bulanan    | `Profit/unit × Total Produksi/Bulan`          |

---

## 6. Analisis BEP (Break Even Point)

```
Contribution Margin/unit = Harga Jual/unit − Biaya Variabel/unit

Biaya Variabel/unit = (Total Biaya Bulanan − Biaya Tetap Bulanan) / Total Produksi/Bulan

BEP Unit = Biaya Tetap Bulanan / Contribution Margin   (dibulatkan ke atas)

BEP Omzet = BEP Unit × Harga Jual/unit

BEP Waktu (bulan) = BEP Unit / Total Produksi per Bulan
```

> **Biaya Tetap** di-auto-populate dari komponen biaya yang ditandai sebagai biaya tetap (toggle pada setiap komponen). Nilai dihitung dalam basis bulanan.

> **Biaya Variabel per Unit** ≠ HPP. HPP menggunakan absorption costing (semua biaya / produksi) untuk keperluan penetapan harga. BEP & Profit Analysis menggunakan contribution margin approach: hanya biaya variabel yang dipisahkan.

### Contoh BEP

Menggunakan data dari contoh produksi harian di atas, dengan asumsi Overhead (Rp 300.000) ditandai sebagai biaya tetap:

- Total Biaya Bulanan: Rp 4.050.000
- Biaya Tetap: Rp 300.000 (overhead)
- Biaya Variabel Bulanan: Rp 4.050.000 − Rp 300.000 = **Rp 3.750.000**
- **Biaya Variabel/unit = Rp 3.750.000 / 250 = Rp 15.000**
- Harga Jual/unit: Rp 21.060
- **Contribution Margin = Rp 21.060 − Rp 15.000 = Rp 6.060**
- **BEP Unit = Rp 300.000 / Rp 6.060 = 50 unit/bulan**
- **BEP Omzet = 50 × Rp 21.060 = Rp 1.053.000**
- **BEP Waktu = 50 / 250 = 0,20 bulan ≈ 6 hari**

> ⚠️ **Perbedaan penting:** Jika salah menggunakan HPP (Rp 16.200) sebagai biaya variabel, CM menjadi hanya Rp 4.860 dan BEP menjadi 62 unit — terlalu tinggi karena biaya tetap sudah dihitung dua kali.

---

## 7. Analisis Profit

Menggunakan **Contribution Margin approach** agar konsisten dengan BEP dan tidak terjadi double-counting biaya tetap.

```
Biaya Variabel/unit = (Total Biaya Bulanan − Biaya Tetap Bulanan) / Total Produksi/Bulan

Contribution Margin/unit = Harga Jual − Biaya Variabel/unit

Total Contribution = Contribution Margin/unit × Target Penjualan

Net Profit = Total Contribution − Biaya Tetap Bulanan

ROI = (Net Profit / Investasi Awal) × 100%

Payback Period = Investasi Awal / Net Profit  [dalam bulan]
```

> **Catatan:** HPP (absorption cost) digunakan untuk penetapan harga jual. BEP dan Profit Analysis menggunakan biaya variabel per unit yang dihitung terpisah.

---

## 8. Hal-hal yang Perlu Dikoreksi / Dipertimbangkan

| No | Isu | Status |
|----|-----|--------|
| 1 | Ditambahkan opsi **Per Batch** pada dropdown komponen biaya. Biaya per-batch = `nilai × frekuensiBatchPerBulan`. Harian/Mingguan/Bulanan tetap untuk overhead umum. | ✅ Sudah diperbaiki |
| 2 | Konversi mingguan menggunakan 52/12 = 4,333. Apakah sudah sesuai? Alternatif: 4 (bulan 4 minggu) | ✅ Sudah diperbaiki |
| 3 | BEP Waktu kini langsung dalam satuan **bulan** (bukan hari), karena basis produksi adalah bulanan | ✅ Sudah diperbaiki |
| 4 | BEP & Profit Analysis sebelumnya menggunakan HPP sebagai biaya variabel → double-counting biaya tetap. Kini menggunakan contribution margin approach. | ✅ Sudah diperbaiki |
| 5 | `breakdownBiayaByPeriode` tidak punya key 'perBatch' → komponen per batch tidak terhitung. | ✅ Sudah diperbaiki |
| 6 | Biaya Tetap untuk BEP di-auto-populate dari toggle "biaya tetap" pada komponen. Jika tidak ada komponen ditandai tetap, user harus isi manual | ℹ️ Sudah by design |
