# frozen_string_literal: true

module Brcobranca
  module Boleto
    class Placeholder < Brcobranca::Boleto::Base
      def initialize(campos = {})
        campos = { carteira: '999' }.merge!(campos)
        super(campos)
      end
    
      def banco
        '999'
      end
    
      def convenio=(valor)
        @convenio = ''.rjust(5, '9')
      end
    
      def conta_corrente=(valor)
        @conta_corrente = ''.rjust(5, '9')
      end
    
      def nosso_numero=(valor)
        @nosso_numero = ''.rjust(8, '9')
      end
    
      def seu_numero=(valor)
        @seu_numero = ''.rjust(7, '9')
      end
    
      def nosso_numero_dv
        "#{agencia}#{conta_corrente}#{carteira}#{nosso_numero}".modulo10
      end
    
      def agencia_conta_corrente_dv
        "#{agencia}#{conta_corrente}".modulo10
      end
    
      def nosso_numero_boleto
        "#{carteira}/#{nosso_numero}-#{nosso_numero_dv}"
      end
    
      def agencia_conta_boleto
        "#{agencia} / #{conta_corrente}-#{agencia_conta_corrente_dv}"
      end
    
      def codigo_barras_segunda_parte
        "#{carteira}#{nosso_numero}#{nosso_numero_dv}#{agencia}#{conta_corrente}#{agencia_conta_corrente_dv}000"
      end
    end  
  end
end
