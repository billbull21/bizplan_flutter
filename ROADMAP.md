# Roadmap Pengembangan Aplikasi Kalkulator HPP
**Business Plan Calculator - Enhanced Features**

---

## 📋 Ringkasan Project

**Aplikasi ini** adalah kalkulator HPP (Harga Pokok Penjualan) yang membantu pengusaha menghitung biaya produksi dan menentukan harga jual produk mereka dengan akurat.

**Status Saat Ini:**
- ✅ Kalkulator HPP dasar (bahan baku, tenaga kerja, overhead, biaya lain)
- ✅ Perhitungan profit margin dan harga jual
- ✅ Template untuk menyimpan perhitungan yang sering digunakan
- ✅ Skala usaha (rumahan, sedang, tinggi)

---

## 🎯 Fitur Baru yang Diusulkan

### 1. **Pembeda Komponen Perhitungan Harian vs Bulanan**
**Tujuan:** Meningkatkan akurasi perhitungan HPP dengan memisahkan biaya berdasarkan frekuensi kejadiannya.

**Rasional:**
- **Bahan Baku** → Biaya harian (dibeli setiap hari/minggu untuk produksi)
- **Overhead Pabrik** → Biaya bulanan (listrik, sewa, perawatan mesin)
- **Tenaga Kerja** → Bisa harian atau bulanan tergantung sistem penggajian
- **Biaya Lain** → Fleksibel (bisa harian atau bulanan)

**Implementasi:**
```dart
enum PeriodeKomponen { 
  harian,    // Untuk bahan baku, upah harian
  mingguan,  // Untuk pembelian berkala
  bulanan    // Untuk overhead, gaji tetap
}

class KomponenBiaya {
  String nama;
  double nilai;
  PeriodeKomponen periode;
  
  // Konversi ke biaya per unit produksi
  double hitungBiayaPerProduksi(int jumlahProduksi, int hariProduksi) {
    switch (periode) {
      case PeriodeKomponen.harian:
        return nilai / jumlahProduksi;
      case PeriodeKomponen.mingguan:
        return (nilai / 7) / jumlahProduksi;
      case PeriodeKomponen.bulanan:
        return (nilai / (hariProduksi ?? 30)) / jumlahProduksi;
    }
  }
}
```

**Value untuk User:**
- ✅ Perhitungan HPP lebih akurat
- ✅ Memahami struktur biaya dengan lebih baik
- ✅ Bisa menyesuaikan dengan pola produksi yang sebenarnya

---

### 2. **Kategorisasi Berdasarkan Use Case / Rentang Waktu**
**Tujuan:** Memberikan fleksibilitas perhitungan HPP berdasarkan skenario bisnis yang berbeda.

**Use Cases yang Diidentifikasi:**

#### A. **Produksi Harian**
- Cocok untuk: Makanan/minuman, produk segar, bakery
- Karakteristik: 
  - Produksi setiap hari
  - Bahan baku habis dalam 1-2 hari
  - Fokus pada volume harian
  
#### B. **Produksi Batch/Berkala**
- Cocok untuk: Handicraft, fashion, produk kemasan
- Karakteristik:
  - Produksi dalam jumlah besar secara berkala
  - Bahan baku bisa disimpan lama
  - Fokus pada efisiensi batch

#### C. **Produksi Bulanan**
- Cocok untuk: Manufaktur, produk industri
- Karakteristik:
  - Target produksi bulanan
  - Overhead tetap per bulan
  - Fokus pada kapasitas produksi

**Implementasi:**
```dart
enum JenisProduksi {
  harian,     // Produksi setiap hari
  batch,      // Produksi berkala dalam jumlah besar
  bulanan,    // Target produksi per bulan
  custom      // User tentukan sendiri periodenya
}

class SettingProduksi {
  JenisProduksi jenis;
  int hariKerjaBulan;      // Default 25 hari
  int jumlahProduksiHarian; // Untuk tipe harian
  int jumlahProduksiBatch;  // Untuk tipe batch
  int frekuensiBatch;       // Berapa kali batch per bulan
}
```

**Value untuk User:**
- ✅ Perhitungan disesuaikan dengan model bisnis
- ✅ Tidak perlu konversi manual
- ✅ Template spesifik per jenis produksi

---

### 3. **Break Even Point (BEP) dan Profit Analysis**
**Tujuan:** Memberikan insight bisnis yang lebih mendalam untuk pengambilan keputusan.

#### **A. Break Even Point (BEP)**

**Metrics yang Dihitung:**

1. **BEP Unit** - Berapa unit yang harus dijual untuk balik modal
   ```
   BEP (Unit) = Fixed Cost / (Harga Jual - Variable Cost per Unit)
   ```

2. **BEP Rupiah** - Berapa omzet yang dibutuhkan untuk BEP
   ```
   BEP (Rp) = BEP (Unit) × Harga Jual per Unit
   ```

3. **BEP Waktu** - Berapa lama untuk mencapai BEP
   ```
   BEP (Hari/Bulan) = BEP (Unit) / Produksi per Hari
   ```

**Implementasi:**
```dart
class BiayaTetapVariabel {
  // Biaya Tetap (Fixed Cost)
  double sewaTempatBulanan;
  double gajiTetapBulanan;
  double penyusutanAlatBulanan;
  double asuransiBulanan;
  
  double get totalBiayaTetap => 
      sewaTempatBulanan + gajiTetapBulanan + 
      penyusutanAlatBulanan + asuransiBulanan;
  
  // Biaya Variabel (Variable Cost)
  double bahanBakuPerUnit;
  double upahBoronganPerUnit;
  double kemasanPerUnit;
  
  double get totalBiayaVariabelPerUnit =>
      bahanBakuPerUnit + upahBoronganPerUnit + kemasanPerUnit;
}

class BEPCalculator {
  final BiayaTetapVariabel biaya;
  final double hargaJual;
  
  int get bepUnit {
    final contributionMargin = hargaJual - biaya.totalBiayaVariabelPerUnit;
    if (contributionMargin <= 0) return -1; // Harga terlalu rendah
    return (biaya.totalBiayaTetap / contributionMargin).ceil();
  }
  
  double get bepRupiah => bepUnit * hargaJual;
  
  int bepWaktu(int produksiPerHari) {
    if (produksiPerHari <= 0) return -1;
    return (bepUnit / produksiPerHari).ceil();
  }
}
```

#### **B. Profit Analysis**

**Metrics yang Dihitung:**

1. **Gross Profit Margin**
   ```
   GPM = ((Harga Jual - HPP) / Harga Jual) × 100%
   ```

2. **Net Profit (setelah biaya tetap)**
   ```
   Net Profit = (Harga Jual - HPP - Biaya Tetap per Unit) × Jumlah Unit
   ```

3. **ROI (Return on Investment)**
   ```
   ROI = (Net Profit / Total Investment) × 100%
   ```

4. **Margin of Safety**
   ```
   MoS = ((Penjualan Aktual - BEP Penjualan) / Penjualan Aktual) × 100%
   ```

5. **Proyeksi Profit** berdasarkan target penjualan

**Implementasi:**
```dart
class ProfitAnalysis {
  final double totalBiaya;
  final double hppPerUnit;
  final double hargaJual;
  final int jumlahProduksi;
  final int targetPenjualan;
  final double biayaTetapBulanan;
  final double investasiAwal;
  
  // Gross Profit Margin
  double get grossProfitMargin => 
      ((hargaJual - hppPerUnit) / hargaJual) * 100;
  
  // Net Profit setelah biaya tetap
  double get netProfit {
    final grossProfit = (hargaJual - hppPerUnit) * targetPenjualan;
    return grossProfit - biayaTetapBulanan;
  }
  
  // ROI
  double get roi {
    if (investasiAwal <= 0) return 0;
    return (netProfit / investasiAwal) * 100;
  }
  
  // Margin of Safety
  double marginOfSafety(int bepUnit) {
    if (targetPenjualan <= 0) return 0;
    return ((targetPenjualan - bepUnit) / targetPenjualan) * 100;
  }
  
  // Proyeksi profit per bulan
  Map<String, double> proyeksiProfit(List<int> targetBulanan) {
    return {
      for (int i = 0; i < targetBulanan.length; i++)
        'Bulan ${i + 1}': (hargaJual - hppPerUnit) * targetBulanan[i] - biayaTetapBulanan
    };
  }
}
```

**Value untuk User:**
- ✅ Tahu berapa unit harus dijual untuk balik modal
- ✅ Bisa set target penjualan yang realistis
- ✅ Memahami kesehatan finansial bisnis
- ✅ Proyeksi profit untuk planning

---

## 📊 Validasi & Kajian Fitur

### ✅ **Fitur 1: Komponen Harian vs Bulanan**

**Keunggulan:**
- Sangat relevan untuk akurasi perhitungan
- Mudah dipahami oleh user
- Mencerminkan realitas bisnis

**Tantangan:**
- User perlu memahami konsep fixed vs variable cost
- Perlu UI yang jelas untuk membedakan

**Solusi:**
- Berikan default smart (bahan baku = harian, overhead = bulanan)
- Tambahkan tooltips/info untuk edukasi
- Mode "Simple" vs "Advanced" untuk fleksibilitas

**Prioritas:** ⭐⭐⭐⭐⭐ (HIGH)

---

### ✅ **Fitur 2: Kategorisasi Use Case**

**Keunggulan:**
- Template spesifik per industri
- Onboarding lebih mudah untuk user baru
- Guided calculation

**Tantangan:**
- Tidak semua bisnis cocok dengan kategori yang ada
- Bisa membingungkan jika terlalu banyak pilihan

**Solusi:**
- Mulai dengan 3 kategori utama (harian, batch, bulanan)
- Tambahkan opsi "Custom" untuk fleksibilitas
- Wizard setup awal untuk memilih kategori

**Prioritas:** ⭐⭐⭐⭐ (MEDIUM-HIGH)

---

### ✅ **Fitur 3: BEP & Profit Analysis**

**Keunggulan:**
- Nilai tambah sangat besar
- Membedakan app dari kompetitor
- Membantu decision making

**Tantangan:**
- Memerlukan data tambahan (biaya tetap, investasi awal)
- Konsep BEP perlu edukasi
- Kompleksitas UI meningkat

**Solusi:**
- Buat section terpisah untuk BEP Analysis
- Gunakan visualisasi (chart/graph) untuk BEP
- Tooltip & tutorial in-app
- Buat mode optional (user bisa skip jika tidak perlu)

**Prioritas:** ⭐⭐⭐⭐⭐ (HIGH) - Killer Feature!

---

## 🗓️ Rencana Implementasi

### **Phase 1: Foundation Enhancement** (2-3 minggu)
**Focus:** Refactor struktur data untuk support fitur baru

**Tasks:**
1. ✅ Refactor `HppCalculator` model
   - Pisahkan biaya menjadi fixed dan variable
   - Tambah field untuk periode komponen
   - Support multiple pricing scenarios

2. ✅ Update database/storage schema
   - Backward compatibility dengan data lama
   - Migration strategy

3. ✅ Create new models
   - `KomponenBiaya` untuk komponen detail
   - `BiayaTetapVariabel` untuk BEP
   - `ProfitAnalysis` untuk analisa profit
   - `SettingProduksi` untuk use case

**Deliverables:**
- Model classes yang extensible
- Unit tests untuk business logic
- Migration script

---

### **Phase 2: Feature - Komponen Harian vs Bulanan** (1-2 minggu)
**Focus:** Implementasi pembeda komponen biaya

**Tasks:**
1. ✅ UI untuk input komponen dengan periode
   - Dropdown untuk memilih periode (harian/mingguan/bulanan)
   - Auto-calculation based on periode

2. ✅ Logic perhitungan
   - Konversi semua ke biaya per unit produksi
   - Support untuk hari kerja custom

3. ✅ Update hasil perhitungan
   - Breakdown biaya per periode
   - Summary view yang jelas

**Deliverables:**
- Enhanced input form
- Accurate cost calculation
- User guide/tutorial

---

### **Phase 3: Feature - Kategorisasi Use Case** (1-2 minggu)
**Focus:** Template berdasarkan jenis produksi

**Tasks:**
1. ✅ Onboarding wizard
   - Pilih jenis bisnis/produksi
   - Setup awal yang guided

2. ✅ Pre-configured templates
   - Template untuk produksi harian
   - Template untuk produksi batch
   - Template untuk produksi bulanan

3. ✅ Dynamic form adjustment
   - Form berubah berdasarkan use case
   - Default values yang smart

**Deliverables:**
- Onboarding flow
- Industry-specific templates
- Use case selector

---

### **Phase 4: Feature - BEP & Profit Analysis** (2-3 minggu)
**Focus:** Advanced analytics untuk decision making

**Tasks:**
1. ✅ BEP Calculator
   - Input untuk biaya tetap
   - Perhitungan BEP (unit, rupiah, waktu)
   - Visualization (chart/graph)

2. ✅ Profit Analysis Dashboard
   - Gross profit margin
   - Net profit calculation
   - ROI calculator
   - Margin of Safety

3. ✅ Projection Tools
   - Profit projection berdasarkan target
   - Scenario analysis (what-if)
   - Export to PDF/Excel

**Deliverables:**
- BEP calculator module
- Profit analysis dashboard
- Charts and visualizations
- Export functionality

---

### **Phase 5: Polish & Enhancement** (1 minggu)
**Focus:** UX improvement dan testing

**Tasks:**
1. ✅ UI/UX refinement
   - Consistent design language
   - Smooth navigation flow
   - Accessibility improvements

2. ✅ Educational content
   - In-app tutorials
   - Tooltips & help text
   - Video tutorials (optional)

3. ✅ Testing & bug fixes
   - User acceptance testing
   - Edge cases handling
   - Performance optimization

**Deliverables:**
- Polished UI/UX
- Comprehensive help system
- Bug-free release

---

## 📈 Expected Impact

### **Business Value:**
1. **Diferensiasi Produk**
   - Bukan hanya kalkulator sederhana
   - Full business planning tool
   - Competitive advantage

2. **User Retention**
   - Lebih banyak value → lebih sticky
   - Advanced features → willing to pay
   - BEP analysis → critical tool untuk bisnis

3. **Monetization Potential**
   - Freemium model: Basic free, Advanced paid
   - BEP & Analysis → Premium feature
   - Export & Reporting → Premium feature

### **User Value:**
1. **Akurasi Perhitungan** (+40%)
   - Pemisahan biaya harian/bulanan
   - Lebih sesuai realitas bisnis

2. **Better Decision Making**
   - Tahu kapan break even
   - Proyeksi profit yang jelas
   - ROI calculation

3. **Time Saving** (-60%)
   - Template per use case
   - Auto-calculation
   - No manual spreadsheet needed

---

## 🎨 UI/UX Recommendations

### **Navigation Structure:**
```
Home/Dashboard
├── Quick Calculate (Simple Mode)
├── Advanced Calculate
│   ├── Setup Produksi (use case)
│   ├── Komponen Biaya (harian/bulanan)
│   ├── Hitung HPP
│   └── Analysis
│       ├── BEP Analysis
│       └── Profit Analysis
├── Templates (saved calculations)
└── Settings
```

### **Key Screens:**

1. **Setup Wizard (First Time)**
   - Pilih jenis bisnis
   - Pilih skala usaha
   - Setup komponen default

2. **Calculator Page (Enhanced)**
   - Tab: Simple / Advanced
   - Komponen biaya dengan periode
   - Live preview hasil

3. **Analysis Dashboard**
   - BEP metrics (card view)
   - Profit chart
   - Actionable insights

4. **Projection Tool**
   - Input target penjualan
   - Monthly profit projection
   - Scenario comparison

---

## 🔧 Technical Considerations

### **State Management:**
- Continue dengan `flutter_bloc` untuk consistency
- Separate blocs untuk:
  - `HppCalculatorBloc`
  - `BepAnalysisBloc`
  - `ProfitAnalysisBloc`
  - `TemplateBloc`

### **Data Persistence:**
- `shared_preferences` untuk settings
- Consider `sqflite` untuk data yang lebih kompleks
- Export/Import JSON untuk backup

### **Charts/Visualization:**
- `fl_chart` → Free, lightweight
- `syncfusion_flutter_charts` → Powerful tapi heavy

### **PDF Export:**
- `pdf` package
- `printing` package

---

## ⚠️ Risks & Mitigation

### **Risk 1: Increased Complexity**
- **Mitigation:** Progressive disclosure, Simple/Advanced mode

### **Risk 2: User Education Curve**
- **Mitigation:** In-app tutorials, tooltips, examples

### **Risk 3: Performance dengan banyak data**
- **Mitigation:** Lazy loading, pagination, caching

### **Risk 4: Backward compatibility**
- **Mitigation:** Data migration, versioning

---

## 📝 Success Metrics

### **Phase 1-2:**
- ✅ 90% perhitungan lebih akurat
- ✅ User dapat membedakan biaya tetap/variabel

### **Phase 3:**
- ✅ 80% user menggunakan template use case
- ✅ Setup time berkurang 50%

### **Phase 4:**
- ✅ 70% user menggunakan BEP analysis
- ✅ User satisfaction score > 4.5/5

### **Overall:**
- ✅ User retention +50%
- ✅ Session duration +100%
- ✅ Premium conversion rate 10-15%

---

## 🚀 Quick Start Implementation

Untuk memulai implementasi, prioritaskan dalam urutan ini:

1. **Week 1-2:** Refactor model & database schema
2. **Week 3-4:** Implementasi komponen harian/bulanan (quick win!)
3. **Week 5-6:** BEP calculator (killer feature!)
4. **Week 7-8:** Profit analysis & visualizations
5. **Week 9:** Use case templates
6. **Week 10:** Polish & testing

---

## 💡 Future Enhancements (Post-Launch)

1. **Cloud Sync** - Backup ke cloud, multi-device
2. **Collaboration** - Share calculations dengan tim
3. **Industry Benchmarks** - Compare dengan industri sejenis
4. **AI Suggestions** - Rekomendasi optimasi berdasarkan ML
5. **Inventory Management** - Track bahan baku
6. **Invoice & Quotation** - Generate dari HPP
7. **Multi-currency** - Support international business

---

## 📞 Next Steps

1. **Review roadmap ini** dengan stakeholders
2. **Prioritize features** berdasarkan resources
3. **Create detailed specs** untuk Phase 1
4. **Setup development environment**
5. **Start implementation!** 🚀

---

**Catatan:**
Roadmap ini bersifat living document dan dapat disesuaikan berdasarkan feedback user dan business needs.

**Last Updated:** 5 Januari 2026
