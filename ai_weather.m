clc;clear;
close all;

%% Import Dataset from CSV File
data = readtable('Sales_Dataset.csv');

months = data.Month';
sales = data.Sales';

%% Display Imported Data
disp('Imported Dataset');
disp(data);

%% Newton Forward Interpolation
n = length(sales);

% Forward Difference Table
diffTable = zeros(n,n);
diffTable(:,1) = sales';

for j = 2:n
    for i = 1:n-j+1
        diffTable(i,j) = diffTable(i+1,j-1) - diffTable(i,j-1);
    end
end

%% Forecast Future Sales
futureMonths = 13:24;
forecast = zeros(size(futureMonths));

for k = 1:length(futureMonths)

    x = futureMonths(k);
    p = x - months(1);

    y = diffTable(1,1);
    term = 1;

    for j = 2:n
        term = term * (p-(j-2))/(j-1);
        y = y + term * diffTable(1,j);
    end

    forecast(k) = y;
end

%% Confidence Intervals
upperBand = forecast * 1.10;
lowerBand = forecast * 0.90;

%% Simpson's 3/8 Rule for Expected Forecast
h = 1;

f = forecast;
N = length(f)-1;

if mod(N,3) ~= 0
    warning('Intervals not multiple of 3. Last points ignored.');
    N = N - mod(N,3);
end

area_expected = f(1) + f(N+1);

sum3 = 0;
sum2 = 0;

for i = 2:N
    if mod(i-1,3)==0
        sum2 = sum2 + f(i);
    else
        sum3 = sum3 + f(i);
    end
end

area_expected = (3*h/8) * ...
    (area_expected + 3*sum3 + 2*sum2);

%% Simpson's 3/8 Rule for Upper Band
f = upperBand;

area_upper = f(1) + f(N+1);

sum3 = 0;
sum2 = 0;

for i = 2:N
    if mod(i-1,3)==0
        sum2 = sum2 + f(i);
    else
        sum3 = sum3 + f(i);
    end
end

area_upper = (3*h/8) * ...
    (area_upper + 3*sum3 + 2*sum2);

%% Simpson's 3/8 Rule for Lower Band
f = lowerBand;

area_lower = f(1) + f(N+1);

sum3 = 0;
sum2 = 0;

for i = 2:N
    if mod(i-1,3)==0
        sum2 = sum2 + f(i);
    else
        sum3 = sum3 + f(i);
    end
end

area_lower = (3*h/8) * ...
    (area_lower + 3*sum3 + 2*sum2);

%% Display Results
disp('====================================');
disp('AI SALES FORECAST RESULTS');
disp('====================================');

fprintf('Expected Annual Sales = %.2f\n', area_expected);
fprintf('Best Case (Upper Band) = %.2f\n', area_upper);
fprintf('Worst Case (Lower Band)= %.2f\n', area_lower);

%% Forecast Table
forecastTable = table( ...
    futureMonths', ...
    forecast', ...
    upperBand', ...
    lowerBand', ...
    'VariableNames', ...
    {'Month','Forecast','UpperBand','LowerBand'});

disp('Forecast Table');
disp(forecastTable);

%% Plot Results
figure;

plot(months,sales,'bo-','LineWidth',2);
hold on;

plot(futureMonths,forecast,'k-*','LineWidth',2);
plot(futureMonths,upperBand,'g--','LineWidth',2);
plot(futureMonths,lowerBand,'r--','LineWidth',2);

xlabel('Month');
ylabel('Sales');
title('AI Sales Forecast with Confidence Intervals');

legend('Historical Sales',...
       'Forecast',...
       'Upper Confidence Band',...
       'Lower Confidence Band',...
       'Location','northwest');

grid on;