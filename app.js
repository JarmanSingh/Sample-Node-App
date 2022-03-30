const express = require('express');
const app = express();
const port = process.env.PORT || "8080";

app.use(function(req, res, next) {
  res.locals.ua = req.get('User-Agent');
  next();
});

app.get('/', (req, res) => {
  const currYear = new Date().getFullYear();
  res.send(`<h1>Demo App</h1> <h3>Welcome to ${currYear}</h3> <p>User Agent: ${res.locals.ua}</p>`);
})

app.listen(port, ()=> {
  console.log(`Listening to port: ${port}`);
})
 
