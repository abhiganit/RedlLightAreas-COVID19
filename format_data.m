% Get order of sheets
[status,sheets] = xlsfinfo('India_datasheet')
% Contacts-All,Home,Other,School,Work & Population
% Initialize a structure for contact matrix
C = cell(1,5)
for i = 1:5
    [num,txt,raw] = xlsread('India_datasheet',i) ;
    C{i} = num
end
Contacts.All = C{1}
Contacts.Home = C{2}
Contacts.Other = C{3}
Contacts.School = C{4}
Contacts.Work = C{5}

% get Population data
%[num,txt,raw] = xlsread('Population_distribution')
Pop_Dist = readtable('Population_distribution.xlsx');
save('IndiaDemo','Contacts','Pop_Dist')
