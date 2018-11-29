FROM python

RUN apt-get update && \ 
    apt-get -qqy install --no-install-recommends ffmpeg
    
RUN mkdir /app
WORKDIR /app
ADD requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt
ADD . /app/
RUN python secret.py secretkey.txt

CMD [ "python", "manage.py", "runserver" , "0.0.0.0:8000"]
