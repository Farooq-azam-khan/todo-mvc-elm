module.exports = {
  purge: {
    enabled: true,
    content: [
      './src/**/*.html', './src/**/*.js', './src/**/*.elm'
    ]
  }
  ,
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
