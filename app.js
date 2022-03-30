const express = require('express');
const app = express();
const port = 3000;

app.use(function(req, res, next) {
  res.locals.ua = req.get('User-Agent');
  next();
});

app.get('/', (req, res) => {
  const currYear = new Date().getFullYear();
  res.send(`<h1>Demo App</h1> <h4>Welcome to ${currYear}</h4> <p>User Agent: ${res.locals.ua}</p>`);
})

app.listen(port, ()=> {
  console.log(`Demo app is up and listening to port: ${port}`);
})
 
