// User routes
const signup = '/signup';
const googleSignup = '/google-signup';
const login = '/login';
const logout = '/logout';
const getProfile = '/profile';
const patchProfile = '/profile';

// Navigation routes
const getHome = '/';
const getHotelsWithTags = '/tags/'; //needs {tag}
const searchHotelsWithName = '/search';
const advanceSearch = '/search/tags';
const fuzzySearch = '/searchbar'; //Fuzzy search for search bar
// const fuzzyTagSearch = '/search/tags';
const getHotelById = '/hotel/'; // needs {hotelId}
const getHotelRecommendationById =
    '/hotel/{hotelId}/reccomendations'; //needs {hotelId}

// Booking routes
const getBookings = '/profile/bookings';
const addNewBooking = '/profile/bookings/'; //needs {hotelId}
const deleteBookingById = '/profile/bookings/'; //needs {bookingId}
const editBookingById = '/profile/bookings/'; //needs {bookingId}
const printBookingPdf = '/profile/bookings/pdf/';

// Review routes
const addReviewToHotel = '/hotel/{hotelId}/review'; //needs {hotelId}
