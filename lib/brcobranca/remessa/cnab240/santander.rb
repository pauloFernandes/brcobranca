# frozen_string_literal: true

module Brcobranca
  module Remessa
    module Cnab240
      class Santander < Brcobranca::Remessa::Cnab240::Base
        # Código de Transmissão
        # Consultar seu gerente para pegar esse código. Geralmente está no e-mail enviado pelo banco.
        attr_accessor :codigo_transmissao
        attr_accessor :mensagem, :codigo_carteira

        validates_presence_of :documento_cedente, :codigo_transmissao, message: 'não pode estar em branco.'
        validates_presence_of :digito_conta, message: 'não pode estar em branco.', if: :conta_padrao_novo?
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'
        validates_length_of :carteira, maximum: 3, message: 'deve ter no máximo 3 dígitos.'
        validates_length_of :codigo_transmissao, maximum: 15, message: 'deve ter no máximo 15 dígitos.'

        def initialize(campos = {})
          campos = {
            aceite: 'N',
            carteira: '101',
            codigo_carteira: '1',
            tipo_documento: '1',
            emissao_boleto: ' ',
            distribuicao_boleto: ' ',
            especie_titulo: '02'
          }.merge!(campos)
          super
        end

        # Monta o registro header do arquivo
        #
        # @return [String]
        #
        def monta_header_arquivo
          header_arquivo = ''                                   # CAMPO                         TAMANHO
          header_arquivo += cod_banco                           # codigo do banco               3
          header_arquivo << '0000'                              # lote do servico               4
          header_arquivo << '0'                                 # tipo de registro              1
          header_arquivo << ''.rjust(8, ' ')                    # uso exclusivo FEBRABAN        8
          header_arquivo << Brcobranca::Util::Empresa.new(documento_cedente, false).tipo # tipo inscricao               1
          header_arquivo << documento_cedente.to_s.rjust(15, '0') # numero de inscricao         15
          header_arquivo << codigo_transmissao                  # Código de Transmissão         15
          header_arquivo << ''.rjust(25, ' ')                   # Reservado (uso Banco)         25
          header_arquivo << empresa_mae.format_size(30)         # nome da empresa               30
          header_arquivo << nome_banco.format_size(30)          # nome do banco                 30
          header_arquivo << ''.rjust(10, ' ')                   # Reservado (uso Banco)         10
          header_arquivo << 1.to_s                              # codigo remessa                1
          header_arquivo << data_geracao                        # data geracao                  8
          header_arquivo << ''.rjust(6, ' ')                    # Reservado (uso Banco)         6
          header_arquivo << sequencial_remessa.to_s.rjust(6, '0') # numero seq. arquivo         6
          header_arquivo << versao_layout_arquivo               # num. versao arquivo           3
          header_arquivo << ''.rjust(74, ' ')                   # Reservado (uso Banco)         74
          header_arquivo
        end

        # Monta o registro header do lote
        #
        # @param nro_lote [Integer]
        #   numero do lote no arquivo (iterar a cada novo lote)
        #
        # @return [String]
        #
        def monta_header_lote(nro_lote)
          header_lote = ''                                      # CAMPO                   TAMANHO
          header_lote += cod_banco                              # codigo banco            3
          header_lote << nro_lote.to_s.rjust(4, '0')            # lote servico            4
          header_lote << '1'                                    # tipo de registro        1
          header_lote << 'R'                                    # tipo de operacao        1
          header_lote << '01'                                   # tipo de servico         2
          header_lote << exclusivo_servico                      # uso exclusivo           2
          header_lote << versao_layout_lote                     # num.versao layout lote  3
          header_lote << ' '                                    # uso exclusivo           1
          header_lote << Brcobranca::Util::Empresa.new(documento_cedente, false).tipo # tipo de inscricao       1
          header_lote << documento_cedente.to_s.rjust(15, '0')  # inscricao cedente       15
          header_lote << ''.rjust(20, ' ')                      # reservado do banco      20
          header_lote << codigo_transmissao                     # codigo de transmissão   15
          header_lote << ''.rjust(5, ' ')                       # reservado do banco      5
          header_lote << empresa_mae.format_size(30)            # nome empresa            30
          header_lote << mensagem_1.to_s.format_size(40)        # 1a mensagem             40
          header_lote << mensagem_2.to_s.format_size(40)        # 2a mensagem             40
          header_lote << sequencial_remessa.to_s.rjust(8, '0')  # numero remessa          8
          header_lote << data_geracao                           # data gravacao           8
          header_lote << ''.rjust(41, ' ')                      # complemento             33

          header_lote
        end

        def cod_banco
          '033'
        end

        def nome_banco
          'SANTANDER'.format_size(30)
        end

        def versao_layout_arquivo
          '040'
        end

        def versao_layout_lote
          '030'
        end

        # Identificacao do titulo da empresa
        #
        # Sobreescreva caso necessário
        def numero(pagamento)
          pagamento.documento.rjust(15, '0')
        end

        # def agencia=(agencia)
        #   @agencia = agencia
        # end

        def agencia
          "#{@agencia.to_s.ljust(5, '0')}"
        end

        def digito_agencia
          ''
        end

        def dv_agencia_cobradora
          ' '
        end

        def identificacao_titulo_empresa(pagamento)
          pagamento.documento_ou_numero.to_s.ljust(25, ' ')
        end

        # @todo: verificar se deve ser forçado. Não encontrei nenhuma informação sobre isso.
        def codigo_baixa(_pagamento)
          '1'
        end

        # def dias_baixa(pagamento)
        #   pagamento.dias_baixa.to_s.rjust(3, '0')
        # end

        def codigo_convenio
          # CAMPO                TAMANHO
          # num. convenio        20 BRANCOS
          ''.rjust(20, ' ')
        end

        def codigo_moeda
          '00'
        end

        def uso_exclusivo_banco_p
          ''.rjust(11, ' ')                                     # uso exclusivo                         11
        end

        def uso_exclusivo_banco_q
          segmento =  ''.rjust(3, '0')                          # reservado (uso Banco)                3
          segmento += ''.rjust(3, '0')                          # reservado (uso Banco)                3
          segmento << ''.rjust(3, '0')                          # reservado (uso Banco)                3
          segmento << ''.rjust(3, '0')                          # reservado (uso Banco)                3
          segmento << ''.rjust(19, ' ')                         # reservado (uso Banco)                19

          segmento
        end

        # Monta o registro trailer do arquivo
        #
        # @param nro_lotes [Integer]
        #   numero de lotes no arquivo
        # @param sequencial [Integer]
        #   numero de registros(linhas) no arquivo
        #
        # @return [String]
        #
        def monta_trailer_arquivo(nro_lotes, sequencial)
          trailer_arquivo = ''                                             # CAMPO                   # TAMANHO
          trailer_arquivo += cod_banco                                     # codigo banco            3
          trailer_arquivo << nro_lotes.to_s.rjust(4, '0')                  # lote de servico         4
          trailer_arquivo << '9'                                           # tipo registro           1
          trailer_arquivo << ''.rjust(9, ' ')                              # uso exclusivo           9
          trailer_arquivo << nro_lotes.to_s.rjust(6, '0')                  # qtde de registros lote  6
          trailer_arquivo << sequencial.to_s.rjust(6, '0')                 # qtde de registros lote  6
          trailer_arquivo << ''.rjust(211, ' ')                            # uso exclusivo           211
          trailer_arquivo
        end

        alias convenio_lote codigo_convenio

        # Informacoes do Código de Transmissão
        #
        # @return [String]
        #
        def info_conta
          # CAMPO                     TAMANHO
          # codigo_transmissao        20
          codigo_transmissao.to_s.rjust(20, ' ')
        end

        def complemento_header
          ''.rjust(29, ' ')
        end

        def complemento_trailer
          ''.rjust(217, ' ')
        end

        def complemento_p(pagamento)
          # CAMPO                                               TAMANHO
          # conta corrente                                      9
          # digito conta                                        1
          # reservado                                           8               brancos
          # nosso numero                                        13

          cc = conta_corrente.rjust(9, '0')
          ccdv = digito_conta
          nosso_numero = pagamento.nosso_numero.rjust(12, '0')
          "#{cc}#{ccdv}#{cc}#{ccdv}#{''.rjust(2, ' ')}#{nosso_numero}"
        end

        def valor_mora(pagamento)
          return format('%.5f', pagamento.valor_mora).delete('.').rjust(15, '0') if pagamento.tipo_mora.to_s == '2'

          pagamento.formata_valor_mora(15)
        end

        # Monta o registro segmento R do arquivo
        #
        # @param pagamento [Brcobranca::Remessa::Pagamento]
        #   objeto contendo os detalhes do boleto (valor, vencimento, sacado, etc)
        # @param nro_lote [Integer]
        #   numero do lote que o segmento esta inserido
        # @param sequencial [Integer]
        #   numero sequencial do registro no lote
        #
        # @return [String]
        #
        def monta_segmento_r(pagamento, nro_lote, sequencial)
          segmento_r = ''                                               # CAMPO                                TAMANHO
          segmento_r += cod_banco                                       # codigo banco                         3
          segmento_r << nro_lote.to_s.rjust(4, '0')                     # lote de servico                      4
          segmento_r << '3'                                             # tipo do registro                     1
          segmento_r << sequencial.to_s.rjust(5, '0')                   # num. sequencial do registro no lote  5
          segmento_r << 'R'                                             # cod. segmento                        1
          segmento_r << ' '                                             # uso exclusivo                        1
          segmento_r << pagamento.identificacao_ocorrencia              # cod. movimento remessa               2
          segmento_r << '0'                                             # cod. desconto 2                      1
          segmento_r << ''.rjust(8, '0')                                # data desconto 2                      8
          segmento_r << ''.rjust(15, '0')                               # valor desconto 2                     15
          segmento_r << ' '                                             # cod. desconto 3                      1
          segmento_r << ''.rjust(8, ' ')                                # data desconto 3                      8
          segmento_r << ''.rjust(15, ' ')                               # valor desconto 3                     15
          segmento_r << pagamento.codigo_multa                          # codigo multa                         1
          segmento_r << data_multa(pagamento)                           # data multa                           8
          segmento_r << pagamento.formata_percentual_multa(15)          # valor multa                          15
          segmento_r << ''.rjust(10, ' ')                               # info pagador                         10
          segmento_r << mensagem[0...80].rjust(80, ' ')                 # mensagem 3                           40
          segmento_r << ''.rjust(61, ' ')                               # complemento de acordo com o banco    61
          segmento_r
        end
      end
    end
  end
end
