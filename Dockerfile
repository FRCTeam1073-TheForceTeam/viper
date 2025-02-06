FROM httpd:2.4

# When changing this list of installed software
# PLEASE ALSO UPDATE the similar list in software-install.sh
RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y \
		git \
		imagemagick \
		libdbd-mysql-perl \
		libcgi-pm-perl \
		libdbi-perl \
		libfile-flock-perl \
		libfile-slurp-perl \
		libfile-touch-perl \
		libhtml-escape-perl \
		libjpeg-turbo-progs \
		libjson-pp-perl \
		libmime-base64-perl \
		libwww-perl \
		perl \
		simple-revision-control \
	&& apt-get clean autoclean \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/{apt,dpkg,cache,log}/ \
	;

# Adjust Apache configuration
RUN sed -E -i '\
		s/\#\s*(LoadModule .*mod_cgi)/\1/g; \
		s/\#\s*(LoadModule .*mod_rewrite)/\1/g; \
		s/^(\s*AllowOverride) None/\1 All\nSetEnv DEBUG 1/g; \
		s|/htdocs|/htdocs/www|g \
		' conf/httpd.conf \
	&& mkdir -p /usr/local/apache2/htdocs/www \
	;

# docker build -t viper-image .
# docker run -d -p 1073:80 --name viper-container -v `pwd`:/usr/local/apache2/htdocs viper-image
# Visit: http://localhost:1073/
# docker exec -it viper-container bash
# docker logs viper-container --follow
# docker container stop viper-container
# docker container rm viper-container
