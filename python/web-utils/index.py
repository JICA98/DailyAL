from bs4 import BeautifulSoup
import requests

def get_id(link: str):
    return link.split('/')[-2]

def save_image(image_url: str, image_name: str):
    with open('./web_assets/' + image_name, 'wb') as handle:
        response = requests.get(image_url, stream=True)

        if not response.ok:
            print(response)

        for block in response.iter_content(1024):
            if not block:
                break

            handle.write(block)

def genre_page(category: str):
    url = 'https://myanimelist.net/{}.php'.format(category)
    soup = BeautifulSoup(requests.get(url).text, 'html.parser')
    ele = soup.select('.genre-link')
    for i in range(min(4, len(ele))):
        e = ele[i]
        a_tags = e.select('a')
        for a in a_tags:
            link = a.attrs['href']
            if link != None:
                link = 'https://myanimelist.net' + link
                genre_soup = BeautifulSoup(requests.get(link).text, 'html.parser')
                image_src = genre_soup.select('.image img')[0].attrs['data-src']
                print('saving for id: {} and link: {}'.format(get_id(link), image_src))
                save_image(image_src, 'genres/{}_{}.jpg'.format(get_id(link), category))
    
# genre_page('manga')