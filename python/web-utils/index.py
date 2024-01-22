import json
from bs4 import BeautifulSoup

eng_arb = json.load(open("./lib/l10n/intl_en.arb"))
genre_link = 'https://myanimelist.net/anime/genre/'
soup = BeautifulSoup(open('./python/web-utils/genre.html').read(), 'html.parser')
genre_map = {}
eng_map_arb = {}
ss_genre_map = ''
for link in soup.find_all('a', {'class': 'genre-name-link'}):
    if(link['href'].__contains__(genre_link)):
        (id, genre) = link['href'].replace(genre_link, '').split('/')
        genre_map[int(id)] = genre

# for anime_genre_map
print(genre_map)
for (id) in genre_map.keys():
    genre = genre_map[id]
    ss_genre_map = ss_genre_map + '{}: S.current.{}, '.format(id, genre)
    if not eng_arb.__contains__(genre):
        eng_map_arb[genre] = genre
print('--------------------------')
# for eng_map_arb
print(json.dumps(eng_map_arb))
print('--------------------------')
# for eng_map_arb
print(ss_genre_map)


