function y = IRC_ss_combined_2input(params_in, u, varargin) %Need to be able to enter no. of inputs and outputs
%Extension of IRC_ss_combined_2input_prev function that allows for variation in
%the number of muscles, inputs, and outputs (despite being called IRC_ss_combined_2input)

if(isempty(varargin))%default
    warning('Number of inputs and outputs not specified. Defaulting to 2');
    num_inputs=2;
    num_outputs=2;
elseif(isscalar(varargin))
    num_inputs=varargin{1};
    num_outputs=2;
else
    num_inputs=varargin{1};
    num_outputs=varargin{2};
end

%For 2-muscle case parameters should be inputted in the form [c1,c2,c3,c4,delta1,delta2,gamma1,delta3,delta4, gamma2], where
%ci is steady-state gain. (form is equivalent for larger numbers of muscles)
if(size(params_in,1)==num_inputs)
    params=params_in;
else
    params=params_in';
end

if(size(u,2)~=num_inputs)
    warning("Specified number of inputs doesn't match dimensions of u");
end

num_muscles=length(params)/(num_inputs+num_outputs+1);

C=zeros(num_outputs, num_muscles);

for out=1:num_outputs
C(out,:)=params(num_muscles*(out-1)+1:num_muscles*out); %Parameters of c are filled in row-wise
end




delta_arr=zeros(num_muscles,num_inputs); %delta2_arr=zeros(num_muscles,1);
gamma1_arr=zeros(num_muscles,1);

for m=1:num_muscles
    for in=1:num_inputs
        delta_arr(m,in)=params(num_outputs*num_muscles+(num_inputs+1)*(m-1)+in); %delta2_arr(m)=params(2*num_muscles+3*m-1); 
    end
    gamma1_arr(m)=params(num_outputs*num_muscles+(num_inputs+1)*m);
end


if(any(any(gamma1_arr<delta_arr)))
    warning('Incorrect parameter definition!!! Please enter params in order delta,delta,gamma');
end

y=zeros(size(u,1), num_outputs);
for i=1:size(u,1)
    w=zeros(num_muscles,1);
    for m=1:num_muscles
        sum_input=0;
        for in=1:num_inputs
            sum_input=sum_input+delta_arr(m,in)*u(i,in);
        end
        w(m)=((exp(sum_input)-1)/(exp(sum_input)+gamma1_arr(m)));
    end
y_vec=C*w;
y(i,:)=y_vec';
end



if(any(isnan(y)))
    warning('Predicted joint outputs are NaN');
end
end

