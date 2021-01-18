 # build tailwind without any purges
 sed -i "s/enabled: true/enabled: false/g" ./tailwind.config.js
 tailwindcss build src/tailwind.css -o src/styles.css

 # start elm development server 
 elm-live ./src/Main.elm --pushstate -- --debug --output=elm.js