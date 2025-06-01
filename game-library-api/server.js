const express = require('express');
const sql = require('mssql');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Veritabanı konfigürasyonu
const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  options: {
    encrypt: true,
    trustServerCertificate: true,
    // trustedConnection: true, 
  }
};

// Veritabanı bağlantısını test et
sql.connect(config).then(() => {
  console.log('SQL Server bağlantısı başarılı');
}).catch(err => {
  console.error('SQL Server bağlantı hatası:', err);
});

// API rotaları
app.get('/', (req, res) => {
  res.send('Game Library API çalışıyor');
});

// En Yüksek Puanlı Oyunlar
app.get('/api/games/top-rated', async (req, res) => {
  try {
    const limit = req.query.limit || 10;
    const pool = await sql.connect(config);
    
    // Oyunları getir
    const gamesResult = await pool.request()
      .input('limit', sql.Int, limit)
      .query(`
        SELECT TOP (@limit)
          o.*, g.GelistiriciAdi, y.YayinciAdi
        FROM Oyunlar AS o
        JOIN Gelistiriciler AS g ON o.GelistiriciID = g.GelistiriciID
        JOIN Yayincilar AS y ON o.YayinciID = y.YayinciID
        WHERE o.OrtalamaPuan IS NOT NULL
        ORDER BY o.OrtalamaPuan DESC
      `);
    
    const games = gamesResult.recordset;
    
    // Her oyun için tür ve etiketleri getir
    for (let game of games) {
      // Türleri getir
      const genresResult = await pool.request()
        .input('gameId', sql.Int, game.OyunID)
        .query(`
          SELECT t.TurAdi
          FROM OyunTurleri ot
          JOIN Turler t ON ot.TurID = t.TurID
          WHERE ot.OyunID = @gameId
        `);
      
      // Etiketleri getir
      const tagsResult = await pool.request()
        .input('gameId', sql.Int, game.OyunID)
        .query(`
          SELECT e.EtiketAdi
          FROM OyunEtiketleri oe
          JOIN Etiketler e ON oe.EtiketID = e.EtiketID
          WHERE oe.OyunID = @gameId
        `);
      
      game.genres = genresResult.recordset.map(g => g.TurAdi);
      game.tags = tagsResult.recordset.map(t => t.EtiketAdi);
    }
    
    res.json(games);
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).send('Sunucu hatası');
  }
});

// Tüm Oyunlar
app.get('/api/games', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query(`
      SELECT o.*, g.GelistiriciAdi, y.YayinciAdi
      FROM Oyunlar o
      JOIN Gelistiriciler g ON o.GelistiriciID = g.GelistiriciID
      JOIN Yayincilar y ON o.YayinciID = y.YayinciID
      ORDER BY o.OyunAdi
    `);
    
    const games = result.recordset;
    
    // Her oyun için tür ve etiketleri getir (örnek olarak ilk 20 oyun için yapıyoruz)
    const limitedGames = games.slice(0, 20);
    
    for (let game of limitedGames) {
      // Türleri getir
      const genresResult = await pool.request()
        .input('gameId', sql.Int, game.OyunID)
        .query(`
          SELECT t.TurAdi
          FROM OyunTurleri ot
          JOIN Turler t ON ot.TurID = t.TurID
          WHERE ot.OyunID = @gameId
        `);
      
      // Etiketleri getir
      const tagsResult = await pool.request()
        .input('gameId', sql.Int, game.OyunID)
        .query(`
          SELECT e.EtiketAdi
          FROM OyunEtiketleri oe
          JOIN Etiketler e ON oe.EtiketID = e.EtiketID
          WHERE oe.OyunID = @gameId
        `);
      
      game.genres = genresResult.recordset.map(g => g.TurAdi);
      game.tags = tagsResult.recordset.map(t => t.EtiketAdi);
    }
    
    res.json(limitedGames);
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).send('Sunucu hatası');
  }
});

// Oyun Detayı
app.get('/api/games/:id', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('gameId', sql.Int, req.params.id)
      .query(`
        SELECT o.*, g.GelistiriciAdi, y.YayinciAdi
        FROM Oyunlar o
        JOIN Gelistiriciler g ON o.GelistiriciID = g.GelistiriciID
        JOIN Yayincilar y ON o.YayinciID = y.YayinciID
        WHERE o.OyunID = @gameId
      `);
    
    if (result.recordset.length === 0) {
      return res.status(404).send('Oyun bulunamadı');
    }
    
    const game = result.recordset[0];
    
    // Türleri getir
    const genresResult = await pool.request()
      .input('gameId', sql.Int, game.OyunID)
      .query(`
        SELECT t.TurAdi
        FROM OyunTurleri ot
        JOIN Turler t ON ot.TurID = t.TurID
        WHERE ot.OyunID = @gameId
      `);
    
    // Etiketleri getir
    const tagsResult = await pool.request()
      .input('gameId', sql.Int, game.OyunID)
      .query(`
        SELECT e.EtiketAdi
        FROM OyunEtiketleri oe
        JOIN Etiketler e ON oe.EtiketID = e.EtiketID
        WHERE oe.OyunID = @gameId
      `);
    
    game.genres = genresResult.recordset.map(g => g.TurAdi);
    game.tags = tagsResult.recordset.map(t => t.EtiketAdi);
    
    res.json(game);
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).send('Sunucu hatası');
  }
});

// Oyun Yorumları
app.get('/api/games/:id/reviews', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('gameId', sql.Int, req.params.id)
      .query(`
        SELECT y.*, u.KullaniciAdi, u.ProfilResmiURL
        FROM Yorumlar y
        JOIN Kullanicilar u ON y.KullaniciID = u.KullaniciID
        WHERE y.OyunID = @gameId
        ORDER BY y.YorumTarihi DESC
      `);
    
    res.json(result.recordset);
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).send('Sunucu hatası');
  }
});

// Tüm Kullanıcılar
app.get('/api/users', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query('SELECT * FROM Kullanicilar');
    res.json(result.recordset);
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).send('Sunucu hatası');
  }
});

// Kullanıcı Detayı
app.get('/api/users/:id', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('userId', sql.Int, req.params.id)
      .query('SELECT * FROM Kullanicilar WHERE KullaniciID = @userId');
    
    if (result.recordset.length === 0) {
      return res.status(404).send('Kullanıcı bulunamadı');
    }
    
    res.json(result.recordset[0]);
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).send('Sunucu hatası');
  }
});

// Kullanıcı Kütüphanesi
app.get('/api/users/:id/library', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('userId', sql.Int, req.params.id)
      .query(`
        SELECT 
          k.KutuphaneKayitID,
          k.KullaniciID,
          k.OyunID,
          k.SahipOlmaTarihi,
          k.OynamaSuresiSaat,
          k.SonOynamaTarihi,
          o.OyunAdi,
          o.KapakGorseliURL
        FROM Kutuphane k
        JOIN Oyunlar o ON k.OyunID = o.OyunID
        WHERE k.KullaniciID = @userId
        ORDER BY k.SonOynamaTarihi DESC, k.SahipOlmaTarihi DESC
      `);
    
    console.log(`Kullanıcı ${req.params.id} için ${result.recordset.length} kütüphane kaydı bulundu`);
    res.json(result.recordset);
  } catch (err) {
    console.error('Kütüphane getirme hatası:', err);
    res.status(500).json({ error: 'Kütüphane verisi alınırken hata oluştu', details: err.message });
  }
});

// Kullanıcı İstek Listesi
app.get('/api/users/:id/wishlist', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('userId', sql.Int, req.params.id)
      .query(`
        SELECT i.*, o.OyunAdi, o.KapakGorseliURL, o.Fiyat
        FROM IstekListesi i
        JOIN Oyunlar o ON i.OyunID = o.OyunID
        WHERE i.KullaniciID = @userId
        ORDER BY i.EklemeTarihi DESC
      `);
    
    res.json(result.recordset);
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).send('Sunucu hatası');
  }
});

// Kullanıcı Yorumları
app.get('/api/users/:id/reviews', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('userId', sql.Int, req.params.id)
      .query(`
        SELECT y.*, u.KullaniciAdi, u.ProfilResmiURL, o.OyunAdi
        FROM Yorumlar y
        JOIN Kullanicilar u ON y.KullaniciID = u.KullaniciID
        JOIN Oyunlar o ON y.OyunID = o.OyunID
        WHERE y.KullaniciID = @userId
        ORDER BY y.YorumTarihi DESC
      `);
    
    res.json(result.recordset);
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).send('Sunucu hatası');
  }
});

// En Çok İstek Listesine Eklenen Oyunlar
app.get('/api/games/most-wishlisted', async (req, res) => {
  try {
    const limit = req.query.limit || 10;
    const pool = await sql.connect(config);
    
    console.log(`En çok istek listesine eklenen oyunlar isteniyor - limit: ${limit}`);
    
    // Önce istek listesi kayıtlarının varlığını kontrol et
    const checkResult = await pool.request().query(`
      SELECT COUNT(*) as TotalWishlistItems FROM IstekListesi
    `);
    
    console.log(`Toplam istek listesi kayıt sayısı: ${checkResult.recordset[0].TotalWishlistItems}`);
    
    if (checkResult.recordset[0].TotalWishlistItems === 0) {
      console.log('Hiç istek listesi kaydı bulunamadı');
      return res.json([]);
    }
    
    const result = await pool.request()
      .input('limit', sql.Int, limit)
      .query(`
        WITH WishlistCounts AS (
          SELECT 
            o.OyunID, 
            o.OyunAdi, 
            o.Aciklama, 
            o.CikisTarihi, 
            o.Fiyat, 
            o.KapakGorseliURL, 
            o.GelistiriciID, 
            o.YayinciID, 
            o.OrtalamaPuan, 
            o.SistemGereksinimleri,
            g.GelistiriciAdi, 
            y.YayinciAdi, 
            COUNT(i.IstekListesiID) as EklenmeSayisi
          FROM Oyunlar o
          INNER JOIN Gelistiriciler g ON o.GelistiriciID = g.GelistiriciID
          INNER JOIN Yayincilar y ON o.YayinciID = y.YayinciID
          INNER JOIN IstekListesi i ON o.OyunID = i.OyunID
          GROUP BY 
            o.OyunID, o.OyunAdi, o.Aciklama, o.CikisTarihi, o.Fiyat, o.KapakGorseliURL, 
            o.GelistiriciID, o.YayinciID, o.OrtalamaPuan, o.SistemGereksinimleri, 
            g.GelistiriciAdi, y.YayinciAdi
          HAVING COUNT(i.IstekListesiID) > 0
        )
        SELECT TOP (@limit) * 
        FROM WishlistCounts 
        ORDER BY EklenmeSayisi DESC
      `);
    
    console.log(`En çok istek listesine eklenen oyunlar - ${result.recordset.length} oyun bulundu`);
    
    const games = result.recordset;
    
    // Her oyun için tür ve etiketleri getir
    for (let game of games) {
      try {
        // Türleri getir
        const genresResult = await pool.request()
          .input('gameId', sql.Int, game.OyunID)
          .query(`
            SELECT t.TurAdi
            FROM OyunTurleri ot
            JOIN Turler t ON ot.TurID = t.TurID
            WHERE ot.OyunID = @gameId
          `);
        
        // Etiketleri getir
        const tagsResult = await pool.request()
          .input('gameId', sql.Int, game.OyunID)
          .query(`
            SELECT e.EtiketAdi
            FROM OyunEtiketleri oe
            JOIN Etiketler e ON oe.EtiketID = e.EtiketID
            WHERE oe.OyunID = @gameId
          `);
        
        game.genres = genresResult.recordset.map(g => g.TurAdi);
        game.tags = tagsResult.recordset.map(t => t.EtiketAdi);
        
        console.log(`Oyun: ${game.OyunAdi} - İstek listesi sayısı: ${game.EklenmeSayisi}`);
      } catch (genreTagError) {
        console.error(`Oyun ${game.OyunID} için tür/etiket getirme hatası:`, genreTagError);
        game.genres = [];
        game.tags = [];
      }
    }
    
    res.json(games);
  } catch (err) {
    console.error('En çok istek listesine eklenen oyunlar hatası:', err);
    console.error('Hata detayı:', err.message);
    console.error('Stack trace:', err.stack);
    res.status(500).json({ 
      error: 'En çok istek listesine eklenen oyunlar alınırken hata oluştu', 
      details: err.message,
      stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
    });
  }
});

// Türlere Göre İstatistikler
app.get('/api/analytics/genres', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query(`
      SELECT 
        t.TurAdi, 
        COUNT(DISTINCT ot.OyunID) as OyunSayisi,
        AVG(o.OrtalamaPuan) as OrtalamaPuan
      FROM Turler t
      JOIN OyunTurleri ot ON t.TurID = ot.TurID
      JOIN Oyunlar o ON ot.OyunID = o.OyunID
      GROUP BY t.TurAdi
      ORDER BY COUNT(DISTINCT ot.OyunID) DESC
    `);
    
    const stats = {};
    result.recordset.forEach(row => {
      stats[row.TurAdi] = {
        count: row.OyunSayisi,
        avgRating: row.OrtalamaPuan || 0
      };
    });
    
    res.json(stats);
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).send('Sunucu hatası');
  }
});

// Etiketlere Göre İstatistikler
app.get('/api/analytics/tags', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query(`
      SELECT 
        e.EtiketAdi, 
        COUNT(DISTINCT oe.OyunID) as OyunSayisi,
        AVG(o.OrtalamaPuan) as OrtalamaPuan,
        COUNT(DISTINCT k.KullaniciID) as KullaniciSayisi
      FROM Etiketler e
      JOIN OyunEtiketleri oe ON e.EtiketID = oe.EtiketID
      JOIN Oyunlar o ON oe.OyunID = o.OyunID
      LEFT JOIN Kutuphane k ON o.OyunID = k.OyunID
      GROUP BY e.EtiketAdi
      ORDER BY COUNT(DISTINCT oe.OyunID) DESC
    `);
    
    const stats = {};
    result.recordset.forEach(row => {
      stats[row.EtiketAdi] = {
        count: row.OyunSayisi,
        avgRating: row.OrtalamaPuan || 0,
        userCount: row.KullaniciSayisi
      };
    });
    
    res.json(stats);
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).send('Sunucu hatası');
  }
});

// Genel İstatistikler
app.get('/api/analytics/overview', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    
    // Toplam oyun sayısı
    const gamesResult = await pool.request().query('SELECT COUNT(*) as TotalGames FROM Oyunlar');
    const totalGames = gamesResult.recordset[0].TotalGames;
    
    // Toplam kullanıcı sayısı
    const usersResult = await pool.request().query('SELECT COUNT(*) as TotalUsers FROM Kullanicilar');
    const totalUsers = usersResult.recordset[0].TotalUsers;
    
    // Toplam yorum sayısı
    const reviewsResult = await pool.request().query('SELECT COUNT(*) as TotalReviews FROM Yorumlar');
    const totalReviews = reviewsResult.recordset[0].TotalReviews;
    
    // Ortalama puan
    const ratingsResult = await pool.request().query('SELECT AVG(OrtalamaPuan) as AvgRating FROM Oyunlar WHERE OrtalamaPuan IS NOT NULL');
    const avgRating = ratingsResult.recordset[0].AvgRating || 0;
    
    res.json({
      totalGames,
      totalUsers,
      totalReviews,
      avgRating
    });
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).send('Sunucu hatası');
  }
});

// Genel İstatistikler - Gerçek API endpoint'leri ekleyelim
app.get('/api/analytics/games-count', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query('SELECT COUNT(*) as count FROM Oyunlar');
    res.json({ count: result.recordset[0].count });
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).json({ error: 'Oyun sayısı alınırken hata oluştu' });
  }
});

app.get('/api/analytics/users-count', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query('SELECT COUNT(*) as count FROM Kullanicilar');
    res.json({ count: result.recordset[0].count });
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).json({ error: 'Kullanıcı sayısı alınırken hata oluştu' });
  }
});

app.get('/api/analytics/reviews-count', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query('SELECT COUNT(*) as count FROM Yorumlar');
    res.json({ count: result.recordset[0].count });
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).json({ error: 'Yorum sayısı alınırken hata oluştu' });
  }
});

app.get('/api/analytics/average-rating', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query('SELECT AVG(CAST(OrtalamaPuan AS FLOAT)) as average FROM Oyunlar WHERE OrtalamaPuan IS NOT NULL');
    res.json({ average: result.recordset[0].average || 0.0 });
  } catch (err) {
    console.error('Hata:', err);
    res.status(500).json({ error: 'Ortalama puan alınırken hata oluştu' });
  }
});

// Sunucuyu başlat
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API sunucusu ${PORT} portunda çalışıyor`);
});