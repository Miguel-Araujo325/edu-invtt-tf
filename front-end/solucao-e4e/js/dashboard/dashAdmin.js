const professorSelect = document.getElementById("professores");
var id = sessionStorage.getItem("id");
const meta = async (id) => {
    try {
        const response = await fetch(`http://98.81.188.68/api/metas/usuario/${id}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });

        if (response.ok) {
            const dados = await response.json();
            return dados.qtdAula;
        } else {
            console.error("Erro na resposta:", response.statusText);
            return null;
        }
    } catch (error) {
        console.error("Erro na requisição:", error);
        return null;
    }
};

async function plotarProximosAgendamentos(id) {
    try {
        const proximosAgendamentosFetch = await fetch(`http://localhost:7000/api/dashboard/ultimos-3-agendamentos-professor/${id}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });

        const cardNovoAgendamento = document.getElementById("agendamentos-futuros");

        if (proximosAgendamentosFetch.status == 204) {
            cardNovoAgendamento.innerHTML = "Não há proximos agendamentos para atender."
        } else if (proximosAgendamentosFetch.status == 200) {
            const respostaProximosAgendamentos = await proximosAgendamentosFetch.json();

            let nomesMeses = ["janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"];

            const diasSemana = {
                "Sunday": "Domingo",
                "Monday": "Segunda",
                "Tuesday": "Terça",
                "Wednesday": "Quarta",
                "Thursday": "Quinta",
                "Friday": "Sexta",
                "Saturday": "Sábado"
            };

            cardNovoAgendamento.innerHTML = "";
            cardNovoAgendamento.innerHTML += respostaProximosAgendamentos.map((agendamento) => {
                let dataString = agendamento.data;
                let data = new Date(dataString);

                let dia = data.getUTCDate();
                let mes = data.getMonth();

                let diaFormatado = dia.toString().padStart(2, '0');
                let nomeMes = nomesMeses[mes];

                // Traduzir o dia da semana
                let diaSemanaPortugues = diasSemana[agendamento.dia_Semana];

                return `
                <div class="box">
                    <div class="data">
                        <h2 class="dia_proxima_data">${diaFormatado}</h2>
                        <p class="mes_proxima_data">${nomeMes}</p>
                    </div>
                    <div class="content">
                        <p class="dia_semana_proxima_data">${diaSemanaPortugues}</p>
                        <p class="horario_proxima_data">${formatarHorario(agendamento.horario_Inicio)}</p>
                        <p class="nome_aluno_proxima_data">${(agendamento.aluno_Nome).split(" ")[0]}</p>
                    </div>
                </div>`;

            }).join('');
        }
    } catch (e) {
        console.log("Erro ao buscar próximos agendamentos" + e)
        document.getElementById("agendamentos-futuros").innerHTML = "Ocorreu um erro ao buscar os agendamentos";
    }
}

async function plotarKPIsProfessor() {
    try {
        const responseAgendamentos = await fetch(`http://98.81.188.68/api/dashboard/qtd-agendamento-mes-professor/${id}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });
        if (responseAgendamentos.ok) {
            const agendamentosData = await responseAgendamentos.json();
            document.getElementById("agendamentos-total").innerHTML = agendamentosData;
        }
    } catch {
        console.log("Erro ao buscar a quantidade de agendamentos");
        document.getElementById("agendamentos-total").innerHTML = 0;
    }

    try {
        const responseAgendamentos = await fetch(`http://localhost:7000/api/dashboard/qtd-agendamento-confirmado-mes-professor/${id}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });
        if (responseAgendamentos.ok) {
            const agendamentosData = await responseAgendamentos.json();
            document.getElementById("agendamentos-confirmado").innerHTML = agendamentosData;
        }
    } catch {
        console.log("Erro ao buscar a quantidade de agendamentos confirmados");
        document.getElementById("agendamentos-confirmado").innerHTML = 0;
    }

    var cancelado;
    try {
        const responseCancelados = await fetch(`http://localhost:7000/api/dashboard/qtd-agendamentos-cancelados/${id}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });
        if (responseCancelados.ok) {
            const canceladosData = await responseCancelados.json();
            cancelado = canceladosData;
        }
    } catch (error) {
        console.log("Erro ao buscar a quantidade de agendamentos cancelados:", error);
    }

    var transferido;
    try {
        const responseTransferidos = await fetch(`http://localhost:7000/api/dashboard/aulas-tranferidas-professor/${id}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });
        if (responseTransferidos.ok) {
            const transferidosData = await responseTransferidos.json();
            transferido = transferidosData;
        }
    } catch (error) {
        console.log("Erro ao buscar a quantidade de aulas transferidas:", error);
    }

    console.log(transferido)
    console.log(cancelado)

    document.getElementById("agendamentos-cancelado").innerHTML = (Number(cancelado) + Number(transferido));

    try {
        const responseConcluido = await fetch(`http://localhost:7000/api/dashboard/aulas-concluidas-professor/${id}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });

        if (responseConcluido.status == 204) {
            document.getElementById("agendamentos-concluido").innerHTML = 0;
        } else if (responseConcluido.ok) {
            const conclusao = await responseConcluido.json();
            document.getElementById("agendamentos-concluido").innerHTML = conclusao.quantidade_Aulas_Concluidas;
        }
    } catch (error) {
        console.log("Erro ao buscar a taxa de cumprimento das metas:", error);
        document.getElementById("agendamento-meta").innerHTML = "0%";
    }

    try {
        const qtdAulaMeta = await meta(id);
        if (qtdAulaMeta !== null) {
            document.getElementById("agendamento-meta").innerHTML = qtdAulaMeta;
        } else {
            document.getElementById("agendamento-meta").innerHTML = "0";
        }
    } catch (error) {
        console.log("Erro ao calcular a meta:", error);
        document.getElementById("agendamento-meta").innerHTML = "0%";
    }
}

async function buscarProfessores() {
    try {
        const response = await fetch('http://98.81.188.68/api/usuarios/professor', {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });

        if (response.ok) {
            const professores = await response.json();
            professores.forEach(professor => {
                const option = document.createElement('option');
                option.value = professor.id;
                option.innerText = professor.nomeCompleto;
                professorSelect.appendChild(option);
            });
        } else if (response.status == 204) {
            Swal.fire({
                title: 'Erro',
                text: 'Não há professores cadastrados.',
                icon: 'error',
                confirmButtonText: 'OK',
                confirmButtonColor: 'red',
                background: '#f2f2f2',
                color: '#333'
            });
        } else {
            Swal.fire({
                title: 'Erro',
                text: 'Erro inesperado.',
                icon: 'error',
                confirmButtonText: 'OK',
                confirmButtonColor: 'red',
                background: '#f2f2f2',
                color: '#333'
            });
        }
    } catch (error) {
        console.error('Erro na requisição:', error);
    }
}

async function buscarQuantidadeAgendamentosTransferidos(id) {
    try {
        const response = await fetch(`http://localhost:7000/api/dashboard/aulas-tranferidas-professor/${id}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });

        if (response.ok) {
            dados = await response.json();
            document.getElementById("aulas-tranferidas-professor").innerHTML = dados;
        }
    } catch (error) {
        console.log(error)
        document.getElementById("aulas-tranferidas-professor").innerHTML = 0;
    }
}

async function buscarComprimentoMeta(id) {
    const periodo = document.getElementById("mes-ano-input").value;
    const mes = periodo.split(' ')[0];
    const ano = periodo.split(' ')[1];

    try {
        const response = await fetch(`http://localhost:7000/api/dashboard/taxa-cumprimento-metas/${id}?mes=${mes}&ano=${ano}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });
        
        if (response.ok) {
            dados = await response.json();
        }
    } catch (error) {
        console.log(error)
    }
}

async function plotarGraficoTaxaCancelamento(id) {
    try {
        const ano = document.getElementById("ano-input").value;
        const response = await fetch(`http://localhost:7000/api/dashboard/taxa-cancelamento-mes/${id}?ano=${ano}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error(`Erro na API: ${response.status} - ${response.statusText}`);
            return;
        }

        const dados = await response.json();

        let taxaCancelamento = {
            labels: ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'],
            datasets: [{
                label: 'Cancelamentos(%)',
                data: Array(12).fill(0),
                fill: false,
                backgroundColor: '#072b59c0',
                borderColor: '#072B59',
                borderWidth: 1
            }]
        };

        const mesMap = {
            'Janeiro': 0,
            'Fevereiro': 1,
            'Março': 2,
            'Abril': 3,
            'Maio': 4,
            'Junho': 5,
            'Julho': 6,
            'Agosto': 7,
            'Setembro': 8,
            'Outubro': 9,
            'Novembro': 10,
            'Dezembro': 11
        };

        if (Array.isArray(dados)) {
            for (let i = 0; i < dados.length; i++) {
                const [mes] = dados[i].mes_Ano.split(' ');
                const mesIndex = mesMap[mes];
                if (mesIndex !== undefined && dados[i].taxa_Cancelamento !== undefined) {
                    taxaCancelamento.datasets[0].data[mesIndex] = dados[i].taxa_Cancelamento;
                }
            }
        }

        if (window.chartTaxaCancelamento instanceof Chart) {
            window.chartTaxaCancelamento.destroy();
        }

        const chartTaxaCancelamentoConfig = {
            type: 'line',
            data: taxaCancelamento,
            options: {
                scales: {
                    y: {
                        beginAtZero: true,
                        min: 0,
                        ticks: {
                            // CALLback: function (value) {
                                return value + '%';
                            }
                        }
                    }
                }
            }
        };

        const chartTaxaCancelamento = new Chart(document.getElementById('chartCancelamento'), chartTaxaCancelamentoConfig);
        window.chartTaxaCancelamento = chartTaxaCancelamento;
    } catch (e) {
        console.error('Erro ao plotar o gráfico:', e);
    }
}

async function plotarGraficoCumprimento(id) {
    try {
        const qtdAulaMeta = await meta(id);

        const periodo = document.getElementById("mes-ano-input").value;
        const mes = periodo.split(' ')[0];
        const ano = periodo.split(' ')[1];

        const response = await fetch(`http://localhost:7000/api/dashboard/aulas-concluidas-todos-meses/${id}?mes=${mes}&ano=${ano}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });

        if (response.ok) {
            const dados = await response.json();

            if (window.barChartMeta instanceof Chart) {
                window.barChartMeta.destroy();
            }

            const ctxBar = document.getElementById('myChartMeta').getContext('2d');
            window.barChartMeta = new Chart(ctxBar, {
                type: 'bar',
                data: {
                    labels: [dados[0].mes],
                    datasets: [
                        {
                            label: 'Meta',
                            data: [qtdAulaMeta],
                            backgroundColor: 'rgba(128, 128, 128, 0.466)',
                            borderColor: 'rgba(128, 128, 128, 0.466)',
                            borderWidth: 1,
                            barThickness: 107,
                            categoryPercentage: 0.6,
                            barPercentage: 0.9
                        },
                        {
                            label: 'Cumprido',
                            data: [dados[0].quantidade_Aulas_Concluidas],
                            backgroundColor: '#072B59',
                            borderColor: '#072B59',
                            borderWidth: 1,
                            barThickness: 107,
                            categoryPercentage: 0.6,
                            barPercentage: 0.9
                        }
                    ]
                },
                options: {
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                display: false
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            }
                        }
                    },
                    plugins: {
                        legend: {
                            display: true,
                            position: 'top'
                        }
                    }
                }
            });
        } else {
            console.error("Erro na resposta do cumprimento:", response.statusText);
        }

    } catch (e) {
        console.error("Erro geral:", e);
    }
}

async function plotarKpiCumprimento(id) {
    const periodo = document.getElementById("mes-ano-input").value;
        const mes = periodo.split(' ')[0];
        const ano = periodo.split(' ')[1];

    try {
        const responseCumprimento = await fetch(`http://localhost:7000/api/dashboard/taxa-cumprimento-metas/${id}?mes=${mes}&ano=${ano}`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${sessionStorage.getItem('token')}`,
                'Content-Type': 'application/json'
            }
        });

        if (responseCumprimento.ok) {
            const cumprimentoData = await responseCumprimento.json();
            if (cumprimentoData.length > 0) {
                const taxaCumprimento = Math.min(Number(cumprimentoData[0].taxa_cumprimento).toFixed(0), 100);
                document.getElementById("agendamento-meta-percentual").innerHTML = `${taxaCumprimento}%`;
            } else {
                document.getElementById("agendamento-meta-percentual").innerHTML = "0%";
            }   
        }
    } catch (error) {
        console.log("Erro ao buscar a taxa de cumprimento das metas:", error);
        document.getElementById("agendamento-meta-percentual").innerHTML = "0%";
    }

}

function limparDadosProfessor() {
    document.getElementById("agendamentos-total").innerHTML = "0";
    document.getElementById("agendamentos-cancelado").innerHTML = "0";
    // document.getElementById("agendamentos-transferido").innerHTML = "0";
    document.getElementById("agendamentos-confirmado").innerHTML = "0";
    document.getElementById("agendamento-meta-percentual").innerHTML = "0";
    document.getElementById("agendamentos-concluido").innerHTML = "0";
    document.getElementById("agendamento-meta").innerHTML = "0";
    document.getElementById("agendamentos-futuros").innerHTML = "0";

    if (window.chartTaxaCancelamento instanceof Chart) {
        window.chartTaxaCancelamento.destroy();
        window.chartTaxaCancelamento = null;
    }

    if (window.barChartMeta instanceof Chart) {
        window.barChartMeta.destroy();
        window.barChartMeta = null;
    }
}

if (Number(sessionStorage.getItem("nivel_acesso_cod")) == 3) {
    document.getElementById("div-professor-select").style.display = "block";
    buscarProfessores();

    professorSelect.addEventListener('change', async (event) => {
        id = professorSelect.value;
        console.log("Professor selecionado: " + id);
        buscarDados(id);
    });
}

async function buscarDados(id) {
    limparDadosProfessor();
    await plotarProximosAgendamentos(id);
    await plotarKPIsProfessor(id);
    await buscarComprimentoMeta(id);
    await plotarGraficoTaxaCancelamento(id);
    await plotarGraficoCumprimento(id);
    plotarKpiCumprimento(id)
}

buscarDados(id);
