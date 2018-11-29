FROM python

RUN apt-get update && \ 
    apt-get -qqy install --no-install-recommends ffmpeg
    
WORKDIR /app
ADD requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
ADD . /app/

CMD [ "python", "manage.py", "runserver" , "0.0.0.0:8000"]
