const express = require('express')
const multer = require('multer');
const url = require('url');
const axios = require('axios');
const { Console } = require('console');




const app = express()
const port = process.env.PORT || 3000

// Configurar la rebuda d'arxius a través de POST
const storage = multer.memoryStorage(); // Guardarà l'arxiu a la memòria
const upload = multer({ storage: storage });

// Tots els arxius de la carpeta 'public' estàn disponibles a través del servidor
// http://localhost:3000/
// http://localhost:3000/images/imgO.png
app.use(express.static('public'))

// Configurar per rebre dades POST en format JSON
app.use(express.json());

// Activar el servidor HTTP
const httpServer = app.listen(port, appListen)
async function appListen() {
  console.log(`Listening for HTTP queries on: http://localhost:${port}`)
}

// Tancar adequadament les connexions quan el servidor es tanqui
process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);
function shutDown() {
  console.log('Received kill signal, shutting down gracefully');
  httpServer.close()
  process.exit(0);
}

// Configurar direcció tipus 'GET' amb la URL ‘/itei per retornar codi HTML
// http://localhost:3000/ieti
app.get('/ieti', getIeti)
async function getIeti(req, res) {

  // Aquí s'executen totes les accions necessaries
  // - fer una petició a un altre servidor
  // - consultar la base de dades
  // - calcular un resultat
  // - cridar la linia de comandes
  // - etc.

  res.writeHead(200, { 'Content-Type': 'text/html' })
  res.end('<html><head><meta charset="UTF-8"></head><body><b>El millor</b> institut del món!</body></html>')
}

// Configurar direcció tipus 'GET' amb la URL ‘/llistat’ i paràmetres URL 
// http://localhost:3000/llistat?cerca=cotxes&color=blau
// http://localhost:3000/llistat?cerca=motos&color=vermell


// Configurar direcció tipus 'POST' amb la URL ‘/data'
// Enlloc de fer una crida des d'un navegador, fer servir 'curl'
// curl -X POST -F "data={\"type\":\"test\"}" -F "file=@package.json" http://localhost:3000/data
// Esto es importate para que se envien los mensajes poco a poco

app.post('/data', upload.single('file'), async (req, res) => {
  if (!req.body.data) {
    return res.status(400).send('Falta el campo de datos.');
  }

  let objPost;
  try {
    objPost = JSON.parse(req.body.data);
    console.log('Mensaje recibido:', objPost);
  } catch (error) {
    return res.status(400).send('JSON mal formado.');
  }

  if (!objPost.type || !objPost.mensaje) {
    return res.status(400).send('Faltan campos necesarios.');
  }

  switch (objPost.type) {
    case 'mistral':
      return handleMistralType(objPost, res);
    case 'llava':
      return handleLlavaType(objPost, res);
    default:
      return res.status(400).send('Tipo de mensaje no soportado.');
  }
});

async function handleMistralType(objPost, res) {
  try {
    const apiResponse = await axios.post('http://localhost:11434/api/generate', {
      model: 'mistral',
      prompt: objPost.mensaje,
    });
    const responses = apiResponse.data.split('\n').filter(line => line.trim() !== '').map(JSON.parse);
    const jsonResponse = { type: 'respuesta', mensaje: responses.map(r => r.response).join('') };
    console.log('Respuesta de la API:', jsonResponse);

    res.status(200).json(jsonResponse);
  } catch (error) {
    console.error('Error al realizar la solicitud a la API:', error);
    res.status(500).send('Error interno del servidor.');
  }
}

async function handleLlavaType(objPost, res) {
  try {
    const apiResponse = await axios.post('http://localhost:11434/api/generate', {
      model: 'llava',
      prompt: objPost.prompt,
      images: [objPost.mensaje],
    });
    const responses = apiResponse.data.split('\n').filter(line => line.trim() !== '').map(JSON.parse);
    const jsonResponse = { type: 'respuesta', mensaje: responses.map(r => r.response).join('') };
    console.log('Respuesta de la API:', jsonResponse);

    res.status(200).json(jsonResponse);
  } catch (error) {
    console.error('Error haciendo la solicitud a la API:', error.message);
    res.status(500).json({ error: 'Error haciendo la solicitud a la API' });
  }
}


