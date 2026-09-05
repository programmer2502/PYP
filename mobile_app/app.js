// PYP Full Application Engine
const creators = [
  {
    id: 'photo_arjun_mehta',
    name: 'Arjun Mehta',
    tagline: 'Vogue Featured • Cinematic Light Specialist',
    categories: ['Wedding', 'Portrait', 'Fashion'],
    styles: ['Cinematic', 'Editorial', 'Moody & Dark', 'Vibrant & Warm'],
    rating: 4.95,
    reviews: 128,
    price: 4999,
    hourly: 2499,
    location: 'Bandra West, Mumbai',
    distance: '1.2 km',
    cover: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=800&q=80',
    equipment: ['Sony A7 IV Body', 'FE 85mm f/1.4 GM', 'FE 50mm f/1.2 GM', 'Profoto B10 Plus', 'Godox AD200 Pro'],
    photos: [
      'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
      'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800&q=80',
      'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=800&q=80'
    ]
  },
  {
    id: 'photo_priya_sharma',
    name: 'Priya Sharma',
    tagline: 'Luxury Destination Wedding & Candid Storyteller',
    categories: ['Wedding', 'Event', 'Portrait', 'Pre-Wedding'],
    styles: ['Candid', 'Vibrant & Warm', 'Cinematic'],
    rating: 4.92,
    reviews: 94,
    price: 7999,
    hourly: 3500,
    location: 'Juhu, Mumbai',
    distance: '3.8 km',
    cover: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
    equipment: ['Canon EOS R5', 'RF 28-70mm f/2 L', 'RF 70-200mm f/2.8 IS', 'Profoto A1X AirTTL'],
    photos: [
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80',
      'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
      'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=800&q=80'
    ]
  },
  {
    id: 'photo_kabir_sen',
    name: 'Kabir Sen',
    tagline: 'Viral Reels & 4K Cinema Drone Specialist',
    categories: ['Reels', 'Drone', 'Event'],
    styles: ['Cinematic', 'Vibrant & Warm', 'Commercial'],
    rating: 4.88,
    reviews: 76,
    price: 3999,
    hourly: 1999,
    location: 'Andheri West, Mumbai',
    distance: '5.4 km',
    cover: 'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=800&q=80',
    equipment: ['Sony FX3 Cinema Line', 'DJI Mavic 3 Pro Cine', 'DJI RS3 Pro Gimbal', 'Sennheiser Wireless Mics'],
    photos: [
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
      'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=800&q=80',
      'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&q=80'
    ]
  },
  {
    id: 'photo_aisha_khan',
    name: 'Aisha Khan',
    tagline: 'High-Fashion & Runway Editorial Director',
    categories: ['Fashion', 'Portrait'],
    styles: ['Editorial', 'Moody & Dark'],
    rating: 4.96,
    reviews: 110,
    price: 6499,
    hourly: 2999,
    location: 'Colaba, Mumbai',
    distance: '8.1 km',
    cover: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
    equipment: ['Hasselblad X2D 100C', 'XCD 80mm f/1.9', 'Broncolor Siros 800L'],
    photos: [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
      'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80'
    ]
  },
  {
    id: 'photo_rohan_verma',
    name: 'Rohan Verma',
    tagline: 'Architectural, Real Estate & Drone Cinematographer',
    categories: ['Commercial', 'Drone'],
    styles: ['Clean & Sharp', 'HDR'],
    rating: 4.85,
    reviews: 62,
    price: 5499,
    hourly: 2200,
    location: 'Worli, Mumbai',
    distance: '4.6 km',
    cover: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&q=80',
    equipment: ['Sony A7R V', '16-35mm f/2.8 GM II', 'DJI Inspire 3'],
    photos: [
      'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&q=80',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80'
    ]
  },
  {
    id: 'photo_vikram_malhotra',
    name: 'Vikram Malhotra',
    tagline: 'Celebrity Concert & Live Event Specialist',
    categories: ['Event', 'Portrait', 'Reels'],
    styles: ['Dynamic', 'Cinematic'],
    rating: 4.90,
    reviews: 88,
    price: 5999,
    hourly: 2800,
    location: 'BKC, Mumbai',
    distance: '2.9 km',
    cover: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800&q=80',
    equipment: ['Nikon Z9', 'NIKKOR Z 70-200mm f/2.8', 'Profoto B10X'],
    photos: [
      'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800&q=80',
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80'
    ]
  }
];

let selectedCategory = 'All';
let selectedCreator = creators[0];
let selectedPackageInfo = { name: 'Editorial Portrait Standard', price: 4999 };

window.addEventListener('DOMContentLoaded', () => {
  // Splash Screen Transition
  setTimeout(() => {
    goToScreen('screen-role-selection');
  }, 1600);

  renderFeatured();
  renderCreators(creators);
});

function goToScreen(screenId) {
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  const target = document.getElementById(screenId);
  if (target) {
    target.classList.add('active');
    target.scrollTop = 0;
  }

  const nav = document.getElementById('main-bottom-nav');
  if (screenId === 'screen-splash' || screenId === 'screen-role-selection' || screenId === 'screen-creator-onboarding') {
    nav.style.display = 'none';
  } else {
    nav.style.display = 'flex';
  }
}

function setActiveNav(el) {
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  el.classList.add('active');
}

function selectRole(role) {
  if (role === 'photographer') {
    goToScreen('screen-creator-onboarding');
  } else {
    goToScreen('screen-home');
  }
}

function saveCreatorProfile(e) {
  e.preventDefault();
  alert('Studio profile saved and synced to Supabase PostgreSQL!');
  goToScreen('screen-creator-dashboard');
}

function renderFeatured() {
  const container = document.getElementById('featured-scroll-container');
  if (!container) return;

  container.innerHTML = creators.slice(0, 3).map(c => `
    <div class="featured-card" onclick="openCreatorDetail('${c.id}')">
      <img class="featured-cover" src="${c.cover}" alt="${c.name}">
      <div class="featured-info">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="font-weight: 700; font-size: 14px; font-family: 'Outfit';">${c.name}</span>
          <span style="font-size: 11px; font-weight: 700; color: #D97706;">★ ${c.rating}</span>
        </div>
        <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;">${c.location}</div>
        <div style="font-size: 13px; font-weight: 800; color: var(--primary); margin-top: 6px; font-family: 'Outfit';">₹ ${c.price.toLocaleString()}</div>
      </div>
    </div>
  `).join('');
}

function renderCreators(list) {
  const container = document.getElementById('creators-container');
  const countLabel = document.getElementById('results-count');
  if (countLabel) countLabel.innerText = `${list.length} Available`;
  if (!container) return;

  if (list.length === 0) {
    container.innerHTML = `
      <div style="text-align: center; padding: 40px 20px;">
        <i class="fa-solid fa-camera" style="font-size: 32px; color: #CBD5E1;"></i>
        <div style="font-weight: 700; margin-top: 12px;">No Creators Found</div>
        <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">Try selecting another category or resetting filters.</p>
      </div>
    `;
    return;
  }

  container.innerHTML = list.map(c => `
    <div class="creator-card" onclick="openCreatorDetail('${c.id}')">
      <div class="creator-cover-wrap">
        <img class="creator-cover" src="${c.cover}" alt="${c.name}">
        <button class="creator-save-btn" onclick="event.stopPropagation(); alert('Saved to Favorites!')">
          <i class="fa-regular fa-heart"></i>
        </button>
      </div>
      <div class="creator-info">
        <div class="creator-header-row">
          <div>
            <div class="creator-name">${c.name} <i class="fa-solid fa-circle-check"></i></div>
            <div class="creator-tagline">${c.tagline}</div>
          </div>
          <div class="rating-badge"><i class="fa-solid fa-star"></i> ${c.rating}</div>
        </div>
        <div class="creator-meta">
          <div class="creator-location"><i class="fa-solid fa-location-dot"></i> ${c.location} • ${c.distance}</div>
          <div class="creator-price">₹ ${c.price.toLocaleString()}</div>
        </div>
      </div>
    </div>
  `).join('');
}

function setCategory(cat, el) {
  selectedCategory = cat;
  document.querySelectorAll('.category-chip').forEach(c => c.classList.remove('active'));
  el.classList.add('active');

  if (cat === 'All') {
    renderCreators(creators);
  } else {
    const filtered = creators.filter(c => c.categories.includes(cat));
    renderCreators(filtered);
  }
}

function filterCreators(query) {
  const q = query.toLowerCase().trim();
  const filtered = creators.filter(c => 
    c.name.toLowerCase().includes(q) ||
    c.tagline.toLowerCase().includes(q) ||
    c.location.toLowerCase().includes(q) ||
    c.categories.some(cat => cat.toLowerCase().includes(q)) ||
    c.styles.some(s => s.toLowerCase().includes(q))
  );
  renderCreators(filtered);
}

function openCreatorDetail(id) {
  selectedCreator = creators.find(c => c.id === id) || creators[0];

  document.getElementById('detail-cover').src = selectedCreator.cover;
  document.getElementById('detail-name').innerText = selectedCreator.name;
  document.getElementById('detail-tagline').innerText = selectedCreator.tagline;
  document.getElementById('detail-rating').innerText = selectedCreator.rating;
  document.getElementById('detail-location').innerHTML = `<i class="fa-solid fa-location-dot" style="color: var(--primary);"></i> ${selectedCreator.location} (${selectedCreator.distance})`;
  document.getElementById('detail-price').innerText = `₹ ${selectedCreator.price.toLocaleString()}`;

  // Styles tags
  const tagsContainer = document.getElementById('detail-styles-tags');
  tagsContainer.innerHTML = selectedCreator.styles.map(s => `<span class="detail-tag">${s}</span>`).join('');

  // Equipment list
  const equipContainer = document.getElementById('detail-equipment-list');
  equipContainer.innerHTML = selectedCreator.equipment.map(e => `
    <div style="display: flex; align-items: center; gap: 8px; font-size: 13px; color: var(--text-main);">
      <i class="fa-solid fa-camera" style="color: var(--primary); font-size: 12px;"></i>
      <span>${e}</span>
    </div>
  `).join('');

  // Portfolio grid
  const grid = document.getElementById('portfolio-images-grid');
  grid.innerHTML = selectedCreator.photos.map(p => `
    <img src="${p}" style="width: 100%; height: 180px; object-fit: cover; border-radius: 12px; cursor: pointer;" onclick="alert('Viewing image in Full Screen Lightbox with Pinch & Zoom')">
  `).join('');

  switchDetailTab('portfolio', document.querySelector('.tab-btn'));
  goToScreen('screen-creator-detail');
}

function switchDetailTab(tabName, el) {
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  el.classList.add('active');

  document.querySelectorAll('.tab-content').forEach(c => c.style.display = 'none');
  const target = document.getElementById(`tab-${tabName}`);
  if (target) target.style.display = 'block';
}

function switchPortfolioType(type, el) {
  document.querySelectorAll('#tab-portfolio .category-chip').forEach(c => c.classList.remove('active'));
  el.classList.add('active');
}

function selectPackage(name, price) {
  selectedPackageInfo = { name, price };
  openBookingModal();
}

function openBookingModal() {
  document.getElementById('modal-booking').classList.add('active');
}

function closeBookingModal() {
  document.getElementById('modal-booking').classList.remove('active');
}

function confirmBooking() {
  closeBookingModal();
  alert(`Booking Confirmed for ₹ ${selectedCreator.price.toLocaleString()} with ${selectedCreator.name}! Your payment is safely held in Escrow.`);
  goToScreen('screen-bookings');
}

function openFilterModal() {
  document.getElementById('modal-filter').classList.add('active');
}

function closeFilterModal() {
  document.getElementById('modal-filter').classList.remove('active');
}

function applyFilters() {
  closeFilterModal();
  renderCreators(creators);
}
