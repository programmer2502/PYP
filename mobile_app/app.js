// PYP Mobile App Engine
const creators = [
  {
    id: 'photo_arjun_mehta',
    name: 'Arjun Mehta',
    tagline: 'Vogue Featured • Cinematic Light Specialist',
    categories: ['Wedding', 'Portrait', 'Fashion'],
    rating: 4.95,
    reviews: 128,
    price: 4999,
    location: 'Bandra West, Mumbai',
    cover: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=800&q=80',
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
    categories: ['Wedding', 'Event', 'Portrait'],
    rating: 4.92,
    reviews: 94,
    price: 7999,
    location: 'Juhu, Mumbai',
    cover: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80',
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
    rating: 4.88,
    reviews: 76,
    price: 3999,
    location: 'Andheri West, Mumbai',
    cover: 'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=800&q=80',
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
    rating: 4.96,
    reviews: 110,
    price: 6499,
    location: 'Colaba, Mumbai',
    cover: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
    photos: [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
      'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80'
    ]
  }
];

let selectedCategory = 'All';
let selectedCreator = null;

// Initialize App
window.addEventListener('DOMContentLoaded', () => {
  // Simulate Splash Transition
  setTimeout(() => {
    goToScreen('screen-role-selection');
  }, 1600);

  renderCreators(creators);
});

function goToScreen(screenId) {
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  const target = document.getElementById(screenId);
  if (target) {
    target.classList.add('active');
    target.scrollTop = 0;
  }

  // Update Nav visibility
  const nav = document.getElementById('main-bottom-nav');
  if (screenId === 'screen-splash' || screenId === 'screen-role-selection' || screenId === 'screen-creator-onboarding') {
    nav.style.display = 'none';
  } else {
    nav.style.display = 'flex';
  }
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

function renderCreators(list) {
  const container = document.getElementById('creators-container');
  if (!container) return;

  if (list.length === 0) {
    container.innerHTML = `
      <div style="text-align: center; padding: 40px 20px;">
        <i class="fa-solid fa-camera" style="font-size: 32px; color: #CBD5E1;"></i>
        <div style="font-weight: 700; margin-top: 12px;">No Creators Found</div>
        <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">Try searching for a different category or style.</p>
      </div>
    `;
    return;
  }

  container.innerHTML = list.map(c => `
    <div class="creator-card" onclick="openCreatorDetail('${c.id}')">
      <img class="creator-cover" src="${c.cover}" alt="${c.name}">
      <div class="creator-info">
        <div class="creator-header-row">
          <div>
            <div class="creator-name">${c.name} <i class="fa-solid fa-circle-check" style="color: var(--primary); font-size: 13px;"></i></div>
            <div class="creator-tagline">${c.tagline}</div>
          </div>
          <div class="rating-badge"><i class="fa-solid fa-star"></i> ${c.rating}</div>
        </div>
        <div class="creator-meta">
          <div style="font-size: 12px; color: var(--text-muted);"><i class="fa-solid fa-location-dot" style="color: var(--primary);"></i> ${c.location}</div>
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
    c.categories.some(cat => cat.toLowerCase().includes(q))
  );
  renderCreators(filtered);
}

function openCreatorDetail(id) {
  selectedCreator = creators.find(c => c.id === id);
  if (!selectedCreator) return;

  document.getElementById('detail-cover').src = selectedCreator.cover;
  document.getElementById('detail-name').innerText = selectedCreator.name;
  document.getElementById('detail-tagline').innerText = selectedCreator.tagline;
  document.getElementById('detail-rating').innerText = selectedCreator.rating;
  document.getElementById('detail-price').innerText = `₹ ${selectedCreator.price.toLocaleString()}`;

  const grid = document.getElementById('portfolio-images-grid');
  grid.innerHTML = selectedCreator.photos.map(p => `
    <img src="${p}" onclick="alert('Full screen portfolio lightbox with pinch & zoom')">
  `).join('');

  goToScreen('screen-creator-detail');
}

function switchPortfolioTab(tab, el) {
  document.querySelectorAll('.portfolio-tab').forEach(t => t.classList.remove('active'));
  el.classList.add('active');
}

function openBooking() {
  if (!selectedCreator) return;
  alert(`Booking session for ₹ ${selectedCreator.price.toLocaleString()} with ${selectedCreator.name}. Payment held safely in escrow until shoot completion!`);
}
