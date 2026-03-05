import { Request, Response, NextFunction } from 'express';
import tributaryService from '../services/tributaryService';

class SimulationController {
  async createTributarySimulation(
    req: Request,
    res: Response,
    next: NextFunction
  ) {
    try {
      const { saleValue, acquisitionCost, otherCosts, regime, year } = req.body;

      if (!saleValue || !acquisitionCost || otherCosts === undefined) {
        return res.status(400).json({ error: 'Dados inválidos' });
      }

      const result = tributaryService.simulateTaxation({
        saleValue,
        acquisitionCost,
        otherCosts,
        regime: regime || 'LP',
        year: year || new Date().getFullYear(),
      });

      res.status(201).json({
        id: `sim_${Date.now()}`,
        ...result,
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new SimulationController();
