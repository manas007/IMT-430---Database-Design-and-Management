import requests
from bs4 import BeautifulSoup
from bs4 import NavigableString
from bs4 import Tag
import pyodbc

baseUrl = 'http://books.toscrape.com/'
additionalurl = 'catalogue/page-'
allresults = []
r = requests.get(baseUrl)
soup = BeautifulSoup(r.text, 'html.parser')
first_res = soup.find('ol', {'class' : 'row'})
allresults.append(first_res)

for i in range(2,51):
    r = requests.get(baseUrl + additionalurl + str(i) + '.html')
    soup = BeautifulSoup(r.text, 'html.parser')
    individual_page_res = soup.find('ol', {'class' : 'row'})
    allresults.append(individual_page_res)

all_titles = list()
all_prices = list()
all_product_descr = list()
all_genres = list()
all_product_urls = list()

for eachRes in allresults:
    if isinstance(eachRes, NavigableString):
        continue
    else:
        for each_a_tag in eachRes.find_all('a', title=True):
            all_titles.append(each_a_tag['title'])
        for each_a_tag in eachRes.find_all('p', {'class':'price_color'}):
            all_prices.append(each_a_tag.text.encode('ascii', errors='ignore').decode())
        for each_a_tag in eachRes.find_all('div', {'class' : 'image_container'}):
            book_url = each_a_tag.find('a', href = True)
            all_product_urls.append(book_url['href'])


for eachURL in all_product_urls:
    if 'catalogue' not in eachURL:
        eachURL = 'catalogue/' + eachURL
    r = requests.get(baseUrl + eachURL)
    soup = BeautifulSoup(r.text, 'html.parser')
    descr = soup.find('meta', {'name' : 'description'})
    all_product_descr.append(descr['content'].strip())
    genres = soup.find('ul', {'class' : 'breadcrumb'})
    breadcrumbs = genres.find_all('a', href=True)
    all_genres.append(breadcrumbs[2].string)


#Database stuff
cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=IS-HAY04.ischool.uw.edu;DATABASE=manas93_BookDB;UID=info430;PWD=GoHuskies!;autocommit=True')

cursor = cnxn.cursor()

for title, price, prod_Descr, genre in zip(all_titles, all_prices, all_product_descr, all_genres):
    sql = """ SET NOCOUNT ON;
    EXECUTE [dbo].[usp_insertBook]
    @bookTitle = ?,
    @bookPrice = ?,
    @bookDesc = ?,
    @genreName = ? """

    bookTitle = title
    bookPrice = price
    bookDesc = prod_Descr
    genreName = genre
   
    params = (
        bookTitle,
        bookPrice,
        bookDesc,
        genreName
    )

    cursor.execute(sql,params)
    
cnxn.commit()
