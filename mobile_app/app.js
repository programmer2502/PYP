// PYP Full Application Engine - Matching Original UI Pixel-Perfect
const creators = [
  {
    id: 'photo_arjun_mehta',
    name: 'Arjun Mehta',
    tagline: 'Vogue Featured • Cinematic Light Specialist',
    categories: ['Wedding', 'Portrait', 'Fashion', 'Reels'],
    styles: ['Cinematic', 'Editorial', 'Moody & Dark', 'Vibrant & Warm'],
    rating: 5.0,
    reviews: 128,
    price: 4999,
    hourly: 2499,
    location: 'Bengaluru',
    city: 'Bengaluru',
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
    categories: ['Wedding', 'Event', 'Portrait'],
    styles: ['Candid', 'Vibrant & Warm', 'Cinematic'],
    rating: 4.9,
    reviews: 94,
    price: 7999,
    hourly: 3500,
    location: 'Bengaluru',
    city: 'Bengaluru',
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
    categories: ['Drone', 'Reels', 'Event'],
    styles: ['Cinematic', 'Vibrant & Warm', 'Commercial'],
    rating: 4.9,
    reviews: 76,
    price: 3999,
    hourly: 1999,
    location: 'Bengaluru',
    city: 'Bengaluru',
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
    categories: ['Portrait', 'Fashion'],
    styles: ['Editorial', 'Moody & Dark'],
    rating: 5.0,
    reviews: 110,
    price: 6499,
    hourly: 2999,
    location: 'Bengaluru',
    city: 'Bengaluru',
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
    categories: ['Drone', 'Event'],
    styles: ['Clean & Sharp', 'HDR'],
    rating: 4.8,
    reviews: 62,
    price: 5499,
    hourly: 2200,
    location: 'Bengaluru',
    city: 'Bengaluru',
    distance: '4.6 km',
    cover: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&q=80',
    equipment: ['Sony A7R V', '16-35mm f/2.8 GM II', 'DJI Inspire 3'],
    photos: [
      'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&q=80',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80'
    ]
  }
];

const categoriesData = [
  { id: 'All', title: 'All', isIcon: true, icon: 'fa-solid fa-camera' },
  { id: 'Wedding', title: 'Wedding', img: 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=150&q=80' },
  { id: 'Portrait', title: 'Portrait', img: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80' },
  { id: 'Event', title: 'Event', img: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=150&q=80' },
  { id: 'Drone', title: 'Drone', img: 'https://images.unsplash.com/photo-1508614589041-895b88991e3e?w=150&q=80' },
  { id: 'Reels', title: 'Reels', isIcon: true, icon: 'fa-solid fa-film' }
];


let selectedCategory = 'All';
let selectedCreator = creators[0];
let selectedPackageInfo = { name: 'Editorial Portrait Standard', price: 4999 };
let savedCreatorIds = ['photo_arjun_mehta', 'photo_priya_sharma', 'photo_aisha_khan', 'photo_kabir_sen'];
let currentLocation = 'Bengaluru';

window.addEventListener('DOMContentLoaded', () => {
  // Splash Screen Transition
  setTimeout(() => {
    goToScreen('screen-role-selection');
  }, 1500);

  renderCategories();
  renderFeatured();
  renderCreators(creators);
  renderSavedCreators();
  renderChatsList();
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

function setActiveNavIndex(index) {
  const items = document.querySelectorAll('.nav-item');
  if (items[index]) {
    setActiveNav(items[index]);
  }
}

function selectRole(role) {
  if (role === 'photographer') {
    goToScreen('screen-creator-onboarding');
  } else {
    goToScreen('screen-home');
    setActiveNavIndex(0);
  }
}

function saveCreatorProfile(e) {
  e.preventDefault();
  showToast('Creator Studio profile saved!');
  goToScreen('screen-creator-dashboard');
}

function renderCategories() {
  const container = document.getElementById('categories-container');
  if (!container) return;

  container.innerHTML = categoriesData.map(cat => `
    <div class="category-item ${selectedCategory === cat.id ? 'active' : ''}" onclick="setCategory('${cat.id}', this)">
      <div class="category-thumb-box">
        ${cat.isIcon ? `<i class="${cat.icon}"></i>` : `<img src="${cat.img}" alt="${cat.title}">`}
      </div>
      <div class="category-title">${cat.title}</div>
    </div>
  `).join('');
}

function renderFeatured() {
  const container = document.getElementById('featured-scroll-container');
  if (!container) return;

  container.innerHTML = creators.map(c => `
    <div class="spotlight-card" onclick="openCreatorDetail('${c.id}')">
      <img class="spotlight-cover" src="${c.cover}" alt="${c.name}">
      <div class="spotlight-gradient"></div>
      <div class="spotlight-content">
        <div class="spotlight-header-row">
          <div class="spotlight-name">${c.name}</div>
          <div class="spotlight-price">₹${c.price.toLocaleString()}</div>
        </div>
        <div class="spotlight-meta-row">
          <span class="open-dot"></span>
          <span style="color: #10B981; font-weight: 700;">Open now</span>
          <span style="color: #F59E0B; margin-left: 6px;">★</span>
          <span style="font-weight: 700;">${c.rating.toFixed(1)} (${c.reviews})</span>
        </div>
        <div class="spotlight-btn-row">
          <button class="btn-spotlight-info" onclick="event.stopPropagation(); openCreatorDetail('${c.id}')">More info</button>
          <button class="btn-spotlight-book" onclick="event.stopPropagation(); selectPackage('Spotlight Session', ${c.price}); openCreatorDetail('${c.id}'); openBookingModal();">Book Now</button>
        </div>
      </div>
    </div>
  `).join('');
}

function renderCreators(list) {
  const container = document.getElementById('creators-container');
  const countLabel = document.getElementById('results-count');
  if (countLabel) countLabel.innerText = `${list.length} verified`;
  if (!container) return;

  if (list.length === 0) {
    container.innerHTML = `
      <div style="text-align: center; padding: 40px 20px;">
        <i class="fa-solid fa-camera" style="font-size: 32px; color: #CBD5E1;"></i>
        <div style="font-weight: 700; margin-top: 12px;">No Photographers Found</div>
        <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">Try selecting another category or resetting filters.</p>
      </div>
    `;
    return;
  }

  container.innerHTML = list.map(c => `
    <div class="photographer-main-card" onclick="openCreatorDetail('${c.id}')">
      <div class="card-image-wrap">
        <img class="card-cover-img" src="${c.cover}" alt="${c.name}">
        <div class="card-rating-pill">
          <span style="color: #F59E0B;">★</span> ${c.rating.toFixed(1)} (${c.reviews})
        </div>
        <div class="card-pro-pill">
          <i class="fa-solid fa-circle-check"></i> PRO
        </div>
      </div>
      <div class="card-body-content">
        <div class="card-top-row">
          <div class="card-title-text">${c.name}</div>
          <div class="card-price-text">From ₹${c.price.toLocaleString()}</div>
        </div>
        <div class="card-subtitle-row">
          <div><i class="fa-solid fa-location-dot" style="color: var(--primary);"></i> ${c.location}</div>
          <div>5y experience</div>
        </div>
        <div class="card-tags-row">
          ${c.styles.slice(0, 3).map(s => `<span class="detail-tag">${s}</span>`).join('')}
        </div>
      </div>
    </div>
  `).join('');
}

function setCategory(cat, el) {
  selectedCategory = cat;
  renderCategories();

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
  document.getElementById('detail-rating').innerText = selectedCreator.rating.toFixed(1);
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
  grid.innerHTML = selectedCreator.photos.map((p, idx) => `
    <img src="${p}" style="width: 100%; height: 180px; object-fit: cover; border-radius: 12px; cursor: pointer;" onclick="openLightbox('${p}', '${selectedCreator.name} - Photo ${idx + 1}', 'Sony A7 IV • 85mm f/1.4 GM • 1/250s • ISO 100')">
  `).join('');

  switchDetailTab('portfolio', document.querySelector('.tab-btn'));
  goToScreen('screen-creator-detail');
}

function switchDetailTab(tabName, el) {
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  if (el) el.classList.add('active');

  document.querySelectorAll('.tab-content').forEach(c => c.style.display = 'none');
  const target = document.getElementById(`tab-${tabName}`);
  if (target) target.style.display = 'block';
}

function switchPortfolioType(type, el) {
  document.querySelectorAll('#tab-portfolio .category-chip').forEach(c => c.classList.remove('active'));
  if (el) el.classList.add('active');
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
  showToast(`Booking confirmed for ₹${selectedCreator.price.toLocaleString()} in Escrow!`);
  goToScreen('screen-bookings');
  setActiveNavIndex(1);
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
  showToast('Filters applied successfully');
}

function openLocationModal() {
  document.getElementById('modal-location').classList.add('active');
}

function closeLocationModal() {
  document.getElementById('modal-location').classList.remove('active');
}

function selectLocation(loc) {
  currentLocation = loc;
  const headerText = document.getElementById('header-location-text');
  if (headerText) headerText.innerText = loc.split(',')[0];
  closeLocationModal();
  showToast(`Location set to ${loc}`);
}

function openEscrowModal() {
  document.getElementById('modal-escrow-info').classList.add('active');
}

function closeEscrowModal() {
  document.getElementById('modal-escrow-info').classList.remove('active');
}

function openLightbox(imgUrl, title, exif) {
  document.getElementById('lightbox-img').src = imgUrl;
  document.getElementById('lightbox-title').innerText = title || 'EXIF High-Res Inspector';
  document.getElementById('lightbox-exif').innerText = exif || 'Sony A7 IV • 85mm f/1.4 GM • 1/250s • ISO 100';
  document.getElementById('modal-lightbox').classList.add('active');
}

function closeLightbox() {
  document.getElementById('modal-lightbox').classList.remove('active');
}

function showToast(msg) {
  const toast = document.getElementById('toast-notice');
  const toastText = document.getElementById('toast-text');
  if (toast && toastText) {
    toastText.innerText = msg;
    toast.classList.add('show');
    setTimeout(() => {
      toast.classList.remove('show');
    }, 2400);
  }
}

function handleSignOut() {
  if (confirm('Are you sure you want to sign out?')) {
    showToast('Signed out of PYP');
    goToScreen('screen-role-selection');
  }
}

function renderSavedCreators() {
  const container = document.getElementById('saved-creators-container');
  const favCountEl = document.getElementById('stat-favorites-count');
  const badgeFavEl = document.getElementById('badge-fav-count');

  if (favCountEl) favCountEl.innerText = savedCreatorIds.length;
  if (badgeFavEl) badgeFavEl.innerText = savedCreatorIds.length;

  if (!container) return;

  const savedList = creators.filter(c => savedCreatorIds.includes(c.id));
  if (savedList.length === 0) {
    container.innerHTML = `
      <div style="text-align: center; padding: 40px 20px;">
        <i class="fa-regular fa-heart" style="font-size: 32px; color: #CBD5E1;"></i>
        <div style="font-weight: 700; margin-top: 12px;">No Saved Photographers</div>
        <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">Tap the heart on any creator to add them to your shortlist.</p>
      </div>
    `;
    return;
  }

  container.innerHTML = savedList.map(c => `
    <div style="background: #FFF; border-radius: 18px; border: 1px solid var(--border); padding: 14px; display: flex; gap: 14px; box-shadow: var(--shadow-sm); cursor: pointer;" onclick="openCreatorDetail('${c.id}')">
      <img src="${c.cover}" style="width: 74px; height: 74px; border-radius: 14px; object-fit: cover;">
      <div style="flex: 1;">
        <div style="display: flex; justify-content: space-between; align-items: flex-start;">
          <div>
            <div style="font-weight: 800; font-size: 15px; font-family: 'Outfit';">${c.name}</div>
            <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;"><i class="fa-solid fa-location-dot" style="color: var(--primary);"></i> ${c.location}</div>
          </div>
          <div style="font-size: 11px; color: #D97706; font-weight: 700;">★ ${c.rating.toFixed(1)}</div>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 10px;">
          <span style="font-size: 14px; font-weight: 800; color: var(--primary); font-family: 'Outfit';">₹ ${c.price.toLocaleString()}</span>
          <button onclick="event.stopPropagation(); selectPackage('Standard Session', ${c.price}); openBookingModal();" class="btn-primary" style="padding: 6px 14px; font-size: 11px; border-radius: 100px;">Book Session</button>
        </div>
      </div>
    </div>
  `).join('');
}

// -------------------------------------------------------------
// REAL-TIME CHAT SYSTEM
// -------------------------------------------------------------
const chatsList = [
  {
    id: 'chat_arjun',
    creatorId: 'photo_arjun_mehta',
    name: 'Arjun Mehta',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&q=80',
    lastMessage: 'I uploaded the moodboard for our sunset shoot! 🌅',
    time: '2m ago',
    unread: 1,
    messages: [
      { sender: 'creator', text: 'Hi! Looking forward to our shoot this Saturday in Bengaluru.', time: '10:30 AM' },
      { sender: 'user', text: 'Hi Arjun! Can we do golden hour portraits near Cubbon Park?', time: '10:32 AM' },
      { sender: 'creator', text: 'Absolutely! I uploaded the moodboard for our sunset shoot! 🌅', time: '10:35 AM' }
    ]
  },
  {
    id: 'chat_priya',
    creatorId: 'photo_priya_sharma',
    name: 'Priya Sharma',
    avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=500&q=80',
    lastMessage: 'Looking forward to the royal pre-wedding session!',
    time: '1h ago',
    unread: 0,
    messages: [
      { sender: 'creator', text: 'Hello! I checked the dates and the location is perfect.', time: '09:15 AM' },
      { sender: 'user', text: 'Great! See you on Saturday.', time: '09:20 AM' }
    ]
  },
  {
    id: 'chat_kabir',
    creatorId: 'photo_kabir_sen',
    name: 'Kabir Sen',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&q=80',
    lastMessage: 'Drone clearance is confirmed for the shoot location 🚁',
    time: 'Yesterday',
    unread: 0,
    messages: [
      { sender: 'creator', text: 'Drone clearance is confirmed for the shoot location 🚁', time: 'Yesterday' }
    ]
  }
];

let activeChat = chatsList[0];

function renderChatsList() {
  const container = document.getElementById('chats-list-container');
  if (!container) return;

  container.innerHTML = chatsList.map(chat => `
    <div onclick="openChatRoom('${chat.id}')" style="background: #FFF; border-radius: 16px; border: 1px solid var(--border); padding: 14px; display: flex; align-items: center; gap: 12px; cursor: pointer; box-shadow: var(--shadow-sm);">
      <div style="position: relative;">
        <img src="${chat.avatar}" style="width: 48px; height: 48px; border-radius: 50%; object-fit: cover;">
        <div style="position: absolute; bottom: 0; right: 0; width: 12px; height: 12px; background: var(--primary); border: 2px solid #FFF; border-radius: 50%;"></div>
      </div>
      <div style="flex: 1;">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="font-family: 'Outfit'; font-weight: 700; font-size: 15px;">${chat.name}</span>
          <span style="font-size: 11px; color: var(--text-muted);">${chat.time}</span>
        </div>
        <div style="font-size: 13px; color: var(--text-muted); margin-top: 3px; display: flex; justify-content: space-between; align-items: center;">
          <span style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 220px;">${chat.lastMessage}</span>
          ${chat.unread > 0 ? `<span style="background: var(--primary); color: #FFF; font-size: 10px; font-weight: 800; width: 18px; height: 18px; border-radius: 50%; display: flex; align-items: center; justify-content: center;">${chat.unread}</span>` : ''}
        </div>
      </div>
    </div>
  `).join('');
}

function openChatRoom(chatId) {
  activeChat = chatsList.find(c => c.id === chatId) || chatsList[0];
  activeChat.unread = 0;

  document.getElementById('chat-room-avatar').src = activeChat.avatar;
  document.getElementById('chat-room-name').innerText = activeChat.name;

  renderMessages();
  goToScreen('screen-chat-room');
}

function renderMessages() {
  const container = document.getElementById('chat-messages-container');
  if (!container) return;

  container.innerHTML = activeChat.messages.map(m => {
    const isMe = m.sender === 'user';
    return `
      <div style="display: flex; justify-content: ${isMe ? 'flex-end' : 'flex-start'};">
        <div style="max-width: 75%; background: ${isMe ? 'var(--primary)' : '#FFF'}; color: ${isMe ? '#FFF' : 'var(--text-main)'}; border: ${isMe ? 'none' : '1px solid var(--border)'}; border-radius: ${isMe ? '18px 18px 4px 18px' : '18px 18px 18px 4px'}; padding: 12px 14px; box-shadow: var(--shadow-sm);">
          <div style="font-size: 13px; line-height: 1.4;">${m.text}</div>
          <div style="font-size: 10px; color: ${isMe ? 'rgba(255,255,255,0.7)' : 'var(--text-muted)'}; text-align: right; margin-top: 4px;">${m.time}</div>
        </div>
      </div>
    `;
  }).join('');

  container.scrollTop = container.scrollHeight;
}

function sendMessage() {
  const input = document.getElementById('chat-input');
  const text = input.value.trim();
  if (!text) return;

  activeChat.messages.push({
    sender: 'user',
    text: text,
    time: 'Just now'
  });
  input.value = '';
  renderMessages();

  // Simulated Creator Instant Reply
  setTimeout(() => {
    activeChat.messages.push({
      sender: 'creator',
      text: 'Got it! Looking forward to creating great shots together! 📸',
      time: 'Just now'
    });
    renderMessages();
  }, 1200);
}
