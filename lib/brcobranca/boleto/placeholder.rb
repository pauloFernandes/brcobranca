# frozen_string_literal: true

module Brcobranca
  module Boleto
    class Placeholder < Base
      def initialize(campos = {})
        campos = { carteira: '' }.merge!(campos)
        super(campos)
      end
    
      def banco
        ''
      end

      def logotipo
        nil
      end
    
      def convenio=(valor)
        @convenio = ''
      end
    
      def conta_corrente=(valor)
        @conta_corrente = ''
      end
    
      def nosso_numero=(valor)
        @nosso_numero = ''
      end
    
      def seu_numero=(valor)
        @seu_numero = ''
      end
    
      def nosso_numero_dv
        ""
      end
    
      def agencia_conta_corrente_dv
        ""
      end
    
      def nosso_numero_boleto
        ""
      end
    
      def agencia_conta_boleto
        ""
      end

      def codigo_barras_primeira_parte
        "000000000000000000"
      end
    
      def codigo_barras_segunda_parte
        "0000000000000000000000000"
      end

      def codigo_barras
        "00000000000000000000000000000000000000000000"
      end
    end  
  end
end
