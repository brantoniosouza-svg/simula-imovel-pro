import Decimal from 'decimal.js';

interface TributaryInput {
  saleValue: number;
  acquisitionCost: number;
  otherCosts: number;
  regime: 'SN' | 'LP' | 'LR';
  year: number;
}

interface TributaryOutput {
  regime: string;
  cbsDebito: number;
  cbsCredito: number;
  cbsLiquido: number;
  irpj: number;
  csll: number;
  totalTax: number;
  lucroLiquido: number;
  cargaTributaria: number;
  roi: number;
}

class TributaryService {
  private getEffectiveAliquot(year: number): number {
    const baseAliquot = 0.28;
    const applicationPercentages: { [key: number]: number } = {
      2027: 0.50,
      2028: 0.57,
      2029: 0.64,
      2030: 0.71,
      2031: 0.79,
      2032: 0.86,
      2033: 1.0,
    };

    const applicationPercentage = applicationPercentages[year] || 1.0;
    return baseAliquot * applicationPercentage;
  }

  private calculateCBS(
    saleValue: number,
    totalCosts: number,
    aliquot: number
  ): { debito: number; credito: number; liquido: number } {
    const debito = new Decimal(saleValue).times(aliquot);
    const credito = new Decimal(totalCosts).times(aliquot);
    const liquido = debito.minus(credito);

    return {
      debito: debito.toNumber(),
      credito: credito.toNumber(),
      liquido: liquido.toNumber(),
    };
  }

  private calculateIRPJ(
    saleValue: number,
    lucro: number,
    regime: 'SN' | 'LP' | 'LR'
  ): number {
    switch (regime) {
      case 'SN':
        return 0;
      case 'LP':
        const presumedProfit = new Decimal(saleValue).times(0.08);
        return presumedProfit.times(0.15).toNumber();
      case 'LR':
        return new Decimal(lucro).times(0.15).toNumber();
      default:
        return 0;
    }
  }

  private calculateCSLL(
    saleValue: number,
    lucro: number,
    regime: 'SN' | 'LP' | 'LR'
  ): number {
    switch (regime) {
      case 'SN':
        return 0;
      case 'LP':
        const presumedProfit = new Decimal(saleValue).times(0.12);
        return presumedProfit.times(0.09).toNumber();
      case 'LR':
        return new Decimal(lucro).times(0.09).toNumber();
      default:
        return 0;
    }
  }

  private calculateSimpleNational(
    saleValue: number,
    lucro: number
  ): TributaryOutput {
    const snAliquot = 0.075;
    const totalTax = new Decimal(saleValue).times(snAliquot);
    const lucroLiquido = new Decimal(lucro).minus(totalTax);

    return {
      regime: 'Simples Nacional',
      cbsDebito: 0,
      cbsCredito: 0,
      cbsLiquido: 0,
      irpj: 0,
      csll: 0,
      totalTax: totalTax.toNumber(),
      lucroLiquido: lucroLiquido.toNumber(),
      cargaTributaria: snAliquot * 100,
      roi: lucroLiquido.dividedBy(saleValue).times(100).toNumber(),
    };
  }

  private calculatePresumptuousProfit(
    saleValue: number,
    totalCosts: number,
    lucro: number,
    aliquot: number
  ): TributaryOutput {
    const cbs = this.calculateCBS(saleValue, totalCosts, aliquot);
    const irpj = this.calculateIRPJ(saleValue, lucro, 'LP');
    const csll = this.calculateCSLL(saleValue, lucro, 'LP');
    const totalTax = new Decimal(cbs.liquido).plus(irpj).plus(csll);
    const lucroLiquido = new Decimal(lucro).minus(totalTax);

    return {
      regime: 'Lucro Presumido',
      cbsDebito: cbs.debito,
      cbsCredito: cbs.credito,
      cbsLiquido: cbs.liquido,
      irpj,
      csll,
      totalTax: totalTax.toNumber(),
      lucroLiquido: lucroLiquido.toNumber(),
      cargaTributaria: totalTax.dividedBy(saleValue).times(100).toNumber(),
      roi: lucroLiquido.dividedBy(saleValue).times(100).toNumber(),
    };
  }

  private calculateRealProfit(
    saleValue: number,
    totalCosts: number,
    lucro: number,
    aliquot: number
  ): TributaryOutput {
    const cbs = this.calculateCBS(saleValue, totalCosts, aliquot);
    const irpj = this.calculateIRPJ(saleValue, lucro, 'LR');
    const csll = this.calculateCSLL(saleValue, lucro, 'LR');
    const totalTax = new Decimal(cbs.liquido).plus(irpj).plus(csll);
    const lucroLiquido = new Decimal(lucro).minus(totalTax);

    return {
      regime: 'Lucro Real',
      cbsDebito: cbs.debito,
      cbsCredito: cbs.credito,
      cbsLiquido: cbs.liquido,
      irpj,
      csll,
      totalTax: totalTax.toNumber(),
      lucroLiquido: lucroLiquido.toNumber(),
      cargaTributaria: totalTax.dividedBy(saleValue).times(100).toNumber(),
      roi: lucroLiquido.dividedBy(saleValue).times(100).toNumber(),
    };
  }

  public simulateTaxation(input: TributaryInput): {
    simpleNational: TributaryOutput;
    presumptuousProfit: TributaryOutput;
    realProfit: TributaryOutput;
    recommendation: string;
  } {
    const totalCosts = input.acquisitionCost + input.otherCosts;
    const lucro = input.saleValue - totalCosts;
    const aliquot = this.getEffectiveAliquot(input.year);

    const simpleNational = this.calculateSimpleNational(input.saleValue, lucro);
    const presumptuousProfit = this.calculatePresumptuousProfit(
      input.saleValue,
      totalCosts,
      lucro,
      aliquot
    );
    const realProfit = this.calculateRealProfit(
      input.saleValue,
      totalCosts,
      lucro,
      aliquot
    );

    let recommendation = 'Simples Nacional';
    let minTax = simpleNational.totalTax;

    if (presumptuousProfit.totalTax < minTax) {
      recommendation = 'Lucro Presumido';
      minTax = presumptuousProfit.totalTax;
    }

    if (realProfit.totalTax < minTax) {
      recommendation = 'Lucro Real';
    }

    return {
      simpleNational,
      presumptuousProfit,
      realProfit,
      recommendation,
    };
  }
}

export default new TributaryService();
