import { Router } from 'express';
import simulationController from '../controllers/simulationController';

const router = Router();

router.post('/', simulationController.createTributarySimulation);

export default router;
