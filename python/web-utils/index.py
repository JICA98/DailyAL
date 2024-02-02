from bs4 import BeautifulSoup
import requests
import json

def get_id(link: str):
    return link.split('/')[-2]

def checkIfImageExistsInDirectory(image_name: str):
    import os.path
    return os.path.isfile('./web_assets/' + image_name)

def save_image(image_url: str, image_name: str):
    if checkIfImageExistsInDirectory(image_name):
        print('image already exists for id: {}'.format(image_name))
        return
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
    genre_desc = {}
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
                desc = genre_soup.select(".genre-description")
                if desc != None and len(desc) > 0:
                    genre_desc[get_id(link)] = genre_soup.select(".genre-description")[0].text
    with open('./web_assets/genre_desc_{}.json'.format(category), 'w') as outfile:
        json.dump(genre_desc, outfile)
    
if __name__ == '__main__':
    # genre_page('manga')
    pass