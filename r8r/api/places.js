// Vercel serverless function to proxy Google Places API requests
// This avoids CORS issues by making server-side requests

export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { type, lat, lng, radius, keyword, placeId, fields } = req.query;

    // Validate required parameters
    if (!type || !lat || !lng) {
      res.status(400).json({ error: 'Missing required parameters: type, lat, lng' });
      return;
    }

    const API_KEY = process.env.GOOGLE_PLACES_API_KEY;
    if (!API_KEY) {
      res.status(500).json({ error: 'Google Places API key not configured' });
      return;
    }

    let url;
    let params = new URLSearchParams({ key: API_KEY });

    if (type === 'nearby') {
      // Nearby search
      url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
      params.append('location', `${lat},${lng}`);
      params.append('radius', radius || '8000');
      params.append('type', 'restaurant');
      if (keyword) params.append('keyword', keyword);
    } else if (type === 'details' && placeId) {
      // Place details
      url = 'https://maps.googleapis.com/maps/api/place/details/json';
      params.append('place_id', placeId);
      params.append('fields', fields || 'name,formatted_address,formatted_phone_number,website,geometry,rating,user_ratings_total,types,business_status,price_level');
    } else {
      res.status(400).json({ error: 'Invalid request type or missing placeId for details' });
      return;
    }

    // Make request to Google Places API
    const response = await fetch(`${url}?${params}`);
    const data = await response.json();

    if (!response.ok) {
      throw new Error(`Google Places API error: ${response.status}`);
    }

    // Return the data
    res.status(200).json(data);
  } catch (error) {
    console.error('Places API proxy error:', error);
    res.status(500).json({ 
      error: 'Internal server error', 
      message: error.message 
    });
  }
}
