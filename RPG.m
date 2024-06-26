%% limpeza
clear
close all
clc

%% Importando dados
dadosimp

entradas = ([dados.Temperatura dados.UmidadeRelativa dados.VelocidadeDoVentoms])';
X = entradas

%entradas2 = entradas(1:1000,:);
saida = (dados.PM10)';

y = saida
%saida2 = saida(1:000,:);


% Extrair as colunas de interesse
temperatura = dados.Temperatura;
umidadeRelativa = dados.UmidadeRelativa;
velocidadeDoVento = dados.VelocidadeDoVentoms;
pm10 = dados.PM10;

% Certifique-se de que os dados são numéricos
temperatura = double(temperatura);
umidadeRelativa = double(umidadeRelativa);
velocidadeDoVento = double(velocidadeDoVento);
pm10 = double(pm10);

% Combinar as variáveis de entrada em uma matriz
X = [temperatura, umidadeRelativa, velocidadeDoVento];
y = pm10;

% Verificar tamanhos das variáveis
disp(['Tamanho de X: ', mat2str(size(X))]);
disp(['Tamanho de y: ', mat2str(size(y))]);

% Reduzir o número de dados para fins de teste
numDados = 1000; % Ajuste este valor conforme necessário
X = X(1:numDados, :);
y = y(1:numDados);

% Normalizar os dados (feature scaling)
mu = mean(X);
sigma = std(X);
X = (X - mu) ./ sigma;

% Adicionar termos polinomiais (features adicionais)
X_poly = [X, X.^2, X.^3, X(:,1).*X(:,2), X(:,1).*X(:,3), X(:,2).*X(:,3)];

% Dividir os dados em conjuntos de treinamento e teste
cv = cvpartition(size(X_poly, 1), 'HoldOut', 0.2);
idxTreinamento = training(cv);
idxTeste = test(cv);

X_treinamento = X_poly(idxTreinamento, :);
y_treinamento = y(idxTreinamento);
X_teste = X_poly(idxTeste, :);
y_teste = y(idxTeste);

% Ajustar os hiperparâmetros do modelo de regressão gaussiana
gprMdl = fitrgp(X_treinamento, y_treinamento, 'KernelFunction', 'ardsquaredexponential', 'FitMethod', 'sr', 'PredictMethod', 'fic');

% Fazer previsões
y_pred = predict(gprMdl, X_teste);

% Calcular RMSE
rmse = sqrt(mean((y_teste - y_pred).^2));
disp(['RMSE: ', num2str(rmse)]);

% Visualização gráfica
figure;
hold on;
plot(y_teste, 'bo');
plot(y_pred, 'r*');
legend('Real', 'Simulação');
xlabel('Amostras');
ylabel('PM10');
title('Comparação entre Real e Simulação');
hold off;

% Operação contínua em tempo real (simulação simplificada)
figure;
hold on;
plot(y, 'bo');
plot(predict(gprMdl, X_poly), 'r*');
legend('Real', 'Simulação');
xlabel('Amostras');
ylabel('PM10');
title('Simulação Contínua em Tempo Real');
hold off;

% Avaliação do modelo com validação cruzada
cvMdl = crossval(gprMdl, 'KFold', 5);
kfoldLoss = kfoldLoss(cvMdl);
disp(['KFold Loss: ', num2str(kfoldLoss)]);