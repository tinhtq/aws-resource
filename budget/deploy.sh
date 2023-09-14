function deploy {
  TIMESTAMP=$(date +%Y%m%d%H%M%S)
  npm i && \
  npm run build && \
  npm prune --production &&\
  mkdir dist &&\
  cp -r ./src/*.js dist/ &&\
  cp -r ./node_modules dist/ &&\
  cd dist &&\
  find . -name "*.zip" -type f -delete && \
  zip -r ../../terraform/zips/lambda_function_"$TIMESTAMP".zip . && \
  cd .. && rm -rf dist 
}


deploy