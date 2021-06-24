const apiKey = 'Enter your tmdb api here';
const newsApiKey = 'Enter your newsApi here';

const imgUrl = 'https://image.tmdb.org/t/p/w500';

const noBackdropPath =
    'https://upload.wikimedia.org/wikipedia/commons/7/75/No_image_available.png';
const noPosterPath =
    'https://cdn.shopify.com/shopifycloud/shopify/assets/no-image-2048-5e88c1b20e087fb7bbe9a3771824e743c244f437e4f8ba93bbf7b11b53f7824c_1200x1200.gif';

const nowplaying =
    'https://api.themoviedb.org/3/movie/now_playing?api_key=${apiKey}';
const popular = 'https://api.themoviedb.org/3/tv/popular?api_key=${apiKey}';
const topRated = 'https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey';
const movieGenres =
    'https://api.themoviedb.org/3/genre/movie/list?api_key=${apiKey}&language=en';
const tvGenres =
    'https://api.themoviedb.org/3/genre/tv/list?api_key=${apiKey}&language=en';
