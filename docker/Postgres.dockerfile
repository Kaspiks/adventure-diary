# PostgreSQL 12 for Adventure Diary
FROM postgres:12

# Configure locale (using en_US for broader compatibility)
RUN localedef \
  --inputfile en_US \
  --force \
  --charmap UTF-8 \
  --alias-file /usr/share/locale/locale.alias \
  en_US.UTF-8

ENV LANG='en_US.utf8'


