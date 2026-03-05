import { useState } from 'react'
import {
  Box,
  Button,
  Card,
  CardContent,
  Grid,
  TextField,
  Typography,
  Alert,
  CircularProgress,
  Container,
  AppBar,
  Toolbar,
} from '@mui/material'
import axios from 'axios'

interface SimulationResult {
  simpleNational: any
  presumptuousProfit: any
  realProfit: any
  recommendation: string
}

function App() {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [result, setResult] = useState<SimulationResult | null>(null)
  const [formData, setFormData] = useState({
    saleValue: 306000,
    acquisitionCost: 170000,
    otherCosts: 69360,
    year: new Date().getFullYear(),
  })

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target
    setFormData((prev) => ({
      ...prev,
      [name]: parseFloat(value) || 0,
    }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError(null)

    try {
      const response = await axios.post(
        'http://localhost:3000/api/v1/simulations',
        {
          type: 'tributaria',
          inputData: formData,
        }
      )
      setResult(response.data)
    } catch (err: any) {
      setError(err.response?.data?.error || 'Erro ao criar simulação')
    } finally {
      setLoading(false)
    }
  }

  return (
    <>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            SimulaImóvel Pro
          </Typography>
        </Toolbar>
      </AppBar>

      <Container maxWidth="lg" sx={{ py: 4 }}>
        <Grid container spacing={3}>
          <Grid item xs={12} md={6}>
            <Card>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Simulador Tributário
                </Typography>
                <Box component="form" onSubmit={handleSubmit} sx={{ mt: 2 }}>
                  <TextField
                    fullWidth
                    label="Valor de Venda"
                    name="saleValue"
                    type="number"
                    value={formData.saleValue}
                    onChange={handleInputChange}
                    margin="normal"
                  />
                  <TextField
                    fullWidth
                    label="Custo de Aquisição"
                    name="acquisitionCost"
                    type="number"
                    value={formData.acquisitionCost}
                    onChange={handleInputChange}
                    margin="normal"
                  />
                  <TextField
                    fullWidth
                    label="Outros Custos"
                    name="otherCosts"
                    type="number"
                    value={formData.otherCosts}
                    onChange={handleInputChange}
                    margin="normal"
                  />
                  <TextField
                    fullWidth
                    label="Ano"
                    name="year"
                    type="number"
                    value={formData.year}
                    onChange={handleInputChange}
                    margin="normal"
                    inputProps={{
                      min: 2027,
                      max: 2033,
                    }}
                  />

                  {error && (
                    <Alert severity="error" sx={{ mt: 2 }}>
                      {error}
                    </Alert>
                  )}

                  <Button
                    fullWidth
                    variant="contained"
                    color="primary"
                    type="submit"
                    sx={{ mt: 3 }}
                    disabled={loading}
                  >
                    {loading ? <CircularProgress size={24} /> : 'Simular'}
                  </Button>
                </Box>
              </CardContent>
            </Card>
          </Grid>

          {result && (
            <Grid item xs={12} md={6}>
              <Card>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Resultados
                  </Typography>

                  <Alert severity="success" sx={{ mb: 2 }}>
                    Regime Recomendado: {result.recommendation}
                  </Alert>

                  <Box sx={{ mb: 2 }}>
                    <Typography variant="body2" color="textSecondary">
                      Carga Tributária (Lucro Presumido)
                    </Typography>
                    <Typography variant="h5" color="primary">
                      {result.presumptuousProfit.cargaTributaria.toFixed(2)}%
                    </Typography>
                  </Box>

                  <Box sx={{ mb: 2 }}>
                    <Typography variant="body2" color="textSecondary">
                      Lucro Líquido
                    </Typography>
                    <Typography variant="h5" color="success.main">
                      R${' '}
                      {result.presumptuousProfit.lucroLiquido.toLocaleString(
                        'pt-BR',
                        { minimumFractionDigits: 2 }
                      )}
                    </Typography>
                  </Box>

                  <Box>
                    <Typography variant="body2" color="textSecondary">
                      ROI
                    </Typography>
                    <Typography variant="h5" color="info.main">
                      {result.presumptuousProfit.roi.toFixed(2)}%
                    </Typography>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          )}
        </Grid>
      </Container>
    </>
  )
}

export default App
