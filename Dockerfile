FROM hugomods/hugo:git-0.122.0 AS build
WORKDIR /page
COPY . .
EXPOSE 1313
ENV HUGO_ENVIRONMENT=production HUGO_ENV=production
RUN hugo --gc --minify

FROM nginx:alpine
COPY --from=build /page/public /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
