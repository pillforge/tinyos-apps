import ipdb

def conv_soc(raw):
    return float(raw)/float(0xffff)

def conv_voltage(raw):
    return float(raw)*6./float(0xffff)

def conv_current(raw):
    return float(raw) * 2.5/(0xfff * 0.0502)

data_conv = { 2: conv_soc,
              3: conv_voltage,
              4: conv_current}

def load_data (file_path):
    data = loadtxt(file_path, converters=data_conv)
    return data

def create_measurements(file_path, clf):
    t,traw,soc,vraw,adc,pwm = loadtxt(file_path, unpack=True)
    soc_norm = soc/float(0xffff)
    U = mat(vraw*6./0xffff).T
    I = mat(adc/0xfff * 2.5/0.0502).T
    X = mat(c_[U, power(U,2), power(U,3), I])
    #X = mat(c_[U, I])
    Q_pred = clf.predict(X)
    measurements = column_stack((Q_pred, I))
    return measurements, soc_norm

def create_measurements_norm(file_path):
    t,traw,soc,vraw,adc,pwm = loadtxt(file_path, unpack=True)
    soc_norm = soc/float(0xffff)
    U = (vraw*6./0xffff)/4.2
    I = (adc/0xfff * 2.5/0.0502)/40
    measurements = column_stack((U, I))
    return measurements, soc_norm

def kalman_filter(zk):
    xk = zeros(NUM_ITER)
    xk[0]=zk[0]
    pk = ones(NUM_ITER)
    for i in range(1,NUM_ITER):
        # Time update
        pk[i] = pk[i-1] + Q
        # Measurement Update

        Gk = pk[i]/(pk[i] + R)
        xk[i] = xk[i-1] + Gk*(zk[i] - xk[i-1])
        pk[i] = (1-Gk)*pk[i]

    return xk

def kalman_filter_2(zk):
    xk = zeros(NUM_ITER)
    xk[0]=zk[0]
    pk = ones(NUM_ITER)
    R = 0
    zmean = zk[0]
    for i in range(1,NUM_ITER):
        # Time update
        pk[i] = pk[i-1] + Q


        # Measurement Update
        # Update measurement covariance
        zmean = ((i-1)*zmean + zk[i])/i
        R = ((i-1)*R + (zk[i] - zmean)**2)/i

        Gk = pk[i]/(pk[i] + R)
        xk[i] = xk[i-1] + Gk*(zk[i] - xk[i-1])
        pk[i] = (1-Gk)*pk[i]

    return xk


def kf_vel1(zk, zk2=None):
    # States are x and v
    #
    # [x] = x_1 + v_1
    # [v] =     + v_1

    xk_out = []
    xk = mat([0.5,0]).T
    pk = mat([[0.5, 0.25],[0.25,1]])

    A = mat([[1, 1],[0,1]])
    #Q2D = mat([[1, 0.5],[0.5,1]])*1e-2

    sv = 1.0
    dt = 1.0
    G = np.matrix([[0.5*dt**2], [dt]])
    Q2D = G*G.T*sv**2

    for i in range(0,NUM_ITER):
        # Time update
        xk = A*xk
        pk = A*pk*A.T + Q2D


        # Measurement Update
        # Update measurement covariance
        #zmean = ((i-1)*zmean + zk[i])/i
        #R = ((i-1)*R + (zk[i] - zmean)**2)/i

        z = vstack((zk[i],zk2[i/10]))
        if zk2 is not None and (i+1)%100 == 0:
            H = mat([[0,0.5],[1,0]])
        else:
            H = mat([[0,0.5],[0,0]])

        Gk = pk*H.T*pinv(H*pk*H.T + diag(R))
        xk = xk + Gk*(z - H*xk)
        xk_out.append(xk)
        pk = (eye(len(pk))-Gk*H)*pk

    return xk_out


def kf_soc1(measurements,dt,B):
    # States are x and v
    #
    # [Q]  = B1*Q_1 + B2*U_1 + B3*I_1
    # [U]  = U_1
    # [I]  = I_1

    xk_out = []
    #xk = mat([0,1,0]).T
    xk = mat([4.2,1.,0.]).T
    pk = mat(eye(len(xk)))

    A = vstack((B.T,
                [0, 1, -dt/(3600*20.)],
                [0, 0, 1],
                ))


    H = mat([[1, 0, 0],
             [0, 0, 1]])

    sv = 1.0
    #G = np.matrix([[0.5*dt**2],[0.5*dt**2],[dt]])
    #G = np.matrix([[dt],[dt],[1e-4]])
    #G = np.matrix([[1e-4],[dt],[1e-4]])
    #Q2D = G*G.T*sv**2

    Q2D = mat(eye(len(xk)))*1e-3

    for i in range(0,len(measurements)):
        # Time update
        #ipdb.set_trace()
        xk = A*xk
        pk = A*pk*A.T + Q2D


        # Measurement Update
        # Update measurement covariance

        z = mat(measurements[i]).T

        Gk = pk*H.T*pinv(H*pk*H.T + diag(R))
        xk = xk + Gk*(z - H*xk)
        xk_out.append(xk.T)
        pk = (eye(len(pk))-Gk*H)*pk

    return array(xk_out).squeeze()



# Track SOC just based on current
def kf_soc2(measurements,dt,B):
    # States are x and v
    #
    # [Q]  = B1*Q_1 + B2*U_1 + B3*I_1
    # [U]  = U_1
    # [I]  = I_1

    xk_out = []
    #xk = mat([0,0,0]).T
    xk = mat([1.,10.]).T
    pk = mat(eye(len(xk)))

    A = vstack(([ 1, -dt/(3600*20.)],
                [ 0, 1],
                ))


    H = mat([[0, 0],
             [0, 1]])

    sv = 1.0
    #G = np.matrix([[0.5*dt**2],[dt]])
    #G = np.matrix([[1e-2],[1e-2]])
    #Q2D = G*G.T*sv**2

    Q2D = mat(eye(len(xk)))*1e-5

    for i in range(0,len(measurements)):
        # Time update
        #ipdb.set_trace()
        xk = A*xk
        pk = A*pk*A.T + Q2D

        # Measurement Update
        # Update measurement covariance

        z = mat(measurements[i]).T

        Gk = pk*H.T*pinv(H*pk*H.T + diag(R))
        xk = xk + Gk*(z - H*xk)
        xk_out.append(xk.T)
        pk = (eye(len(pk))-Gk*H)*pk

    return array(xk_out).squeeze()

# Track SOC based on calculated initial Q and current
def kf_soc3(measurements,dt,B):
    # States are x and v
    #
    # [Q]  = B1*Q_1 + B2*U_1 + B3*I_1
    # [U]  = U_1


    xk_out = []
    #xk = mat([0,0,0]).T
    xk = mat([1.0,10.]).T
    pk = mat(eye(len(xk)))

    A = vstack(([ 1, -dt/(3600*20.)],
                [ 0, 1],
                ))


    H = mat([[1, 0],
             [0, 1]])

    sv = 1.0
    #G = np.matrix([[0.5*dt**2],[dt]])
    #G = np.matrix([[1e-2],[1e-2]])
    #Q2D = G*G.T*sv**2

    Q2D = mat(eye(len(xk)))*1e-1
    Rmat = diag(R)

    for i in range(0,len(measurements)):
        # Time update
        #ipdb.set_trace()
        xk = A*xk
        pk = A*pk*A.T + Q2D

        # Measurement Update
        # Update measurement covariance

        if i == 1000:
            H = mat([[0, 0],
                    [0, 1]])

            #Rmat = Rmat * diag([100, 1])

        z = mat(measurements[i]).T

        Gk = pk*H.T*pinv(H*pk*H.T + Rmat)
        xk = xk + Gk*(z - H*xk)
        xk_out.append(xk.T)
        pk = (eye(len(pk))-Gk*H)*pk

    return array(xk_out).squeeze()

def low_var_sampler(particles, weights, resample=False):
    """@todo: Docstring for low_var_sampler.

    :particles: @todo
    :weights: @todo
    :returns: @todo

    """
    n_resampled = 100
    M = int(0.9 * len(particles))

    r = random_sample()/M
    new_particles = []
    new_weights = []
    i = 0
    c = weights[0]

    for m in range(0,M):
        U = r + float(m)/M
        while U > c:
            i+= 1
            c+= weights[i]
        new_particles.append(particles[i])
        new_weights.append(weights[i])

    if len(new_particles) < 10:
        if resample:
            #current_mean = particles.T.dot(weights)
            #resampled_particles = 0.1*randn(n_resampled, len(current_mean)) + current_mean
            #resampled_particles = multivariate_normal(current_mean, diag([0.001, 0.001]), n_resampled)
            resampled_particles = random_sample((n_resampled,2))
            resampled_weights = ones(n_resampled)/n_resampled
            particles = vstack((particles, resampled_particles))
            cond = ((particles[:,0] >= 0) & (particles[:,1] >= 0) & (particles[:,0] <= 1) & (particles[:,1] <= 1) )
            weights = hstack((weights, resampled_weights))
            particles = particles[cond]
            weights = weights[cond]
        return particles,weights

    return array(new_particles), array(new_weights)

import time

def particle_filter(measurements, dt):
    """@todo: Docstring for particle_filter.

    :measurements: @todo
    :returns: @todo

    """
    n_particles = 1000
    particles = random_sample(n_particles)
    weights = ones(n_particles)/n_particles

    particles_out = []

    batt_capacity = 20. # mah
    q_sigma = 0.5

    #particles_out.append(particles)
    for i in range(0,len(measurements)):

        for p in range(0, len(particles)):
            particles[p] = particles[p] - dt*measurements[i][1]/(3600*batt_capacity)

        particles = particles[(particles[:,0] >= 0) & (particles[:,1] >= 0) & (particles[:,0] <= 1) & (particles[:,1] <= 1) ]
        #particles = particles[particles <= 1]
        weights = normpdf(particles, measurements[i][0], q_sigma)
        weights = weights/weights.sum()
        particles, weights = low_var_sampler(particles, weights)
        weights = weights/weights.sum()

        #particles_out.append(particles)
        particles_out.append(particles.dot(weights))

        #if len(particles) < 10:
        #    return particles_out

    return particles_out

def norm_2d_pdf(x, mean, cov):
    """Calculate the pdf of a 2D gaussian

    :x: @todo
    :mean: @todo
    :cov: @todo
    :returns: @todo

    """
    x = asarray(x)
    u = asarray(mean)
    cov = asarray(cov)

    x_u = x-u

    return exp(-0.5*x_u.dot(inv(cov)).dot(x_u))/(2*pi*sqrt(det(cov)))

def norm_2d_pdf_fast(mean, cov):
    """Returns a function that computes the 2d pdf

    :mean: @todo
    :cov: @todo
    :returns: @todo

    """
    cov = asarray(cov)
    i_cov = inv(cov)
    s_det_cov = 2*pi*sqrt(det(cov))
    u = asarray(mean)

    def _impl_pdf(x):
        x_u = x - u
        return exp(-0.5*x_u.dot(i_cov).dot(x_u))/s_det_cov

    return _impl_pdf

# Particle filter with SOC and U as states
def particle_filter2(measurements, dt, clf):
    """Particle filter with SOC and U as states

    The states are:
        [x_1] = [U(k)]
        [x_2] = [z(k+1)]

    The obserations are:
        [y_1] = [F(r(k))]
        [y_2] = [x_1]

    where r(k) = [x_1, x_2, i]^T

    :measurements: [U(k), U(k-1), i(k)]
    :returns: @todo

    """
    n_particles = 1000
    n_resampled = 100
    particles = random_sample((n_particles,2))
    weights = ones(n_particles)/n_particles

    particles_out = []

    batt_capacity = 20. # mah
    #v_sigma = [0.5, 0.5]
    v_sigma = [0.001, 0.001]

    current_denorm = 40.

    #ipdb.set_trace()
    #scatter(particles[:,0], particles[:,1], c='b', alpha=0.5)
    #pause(0.1)
    #xlim([0,1])
    #ylim([0,1])

    #particles_out.append(particles)
    for i in range(0,len(measurements)):

        x_1 = particles[:,0].copy() # Make a copy for later use in measurement update
        for p in range(0, len(particles)):
            # U = f(U_1, Q, I)
            r_k = hstack((particles[p][0], particles[p][1], measurements[i][2]))
            particles[p][0] = clf.predict(r_k)
            particles[p][1] = particles[p][1] - dt*measurements[i][2]*current_denorm/(3600*batt_capacity)

        # We sample based on the observation vector which is given by:
        #  [y_1] = [F(r(k))]
        #  [y_2] = [x_1]

        # Create a pdf instance with the mean around the measured value
        pdf = norm_2d_pdf_fast(measurements[i,:2], diag(v_sigma))
        #particles = particles[particles >= 0]
        #particles = particles[particles <= 1]

        # Transform our state to an observation vector
        o_k = column_stack((particles[:,0], x_1))

        weights = array([pdf(o) for o in o_k])

        #ipdb.set_trace()
        weights = weights/weights.sum()
        #particles, weights = low_var_sampler(particles, weights, resample=True)
        particles, weights = low_var_sampler(particles, weights)
        weights = weights/weights.sum()

        #particles_out.append(particles)
        mp = particles.T.dot(weights)
        #scatter(particles[:,0], particles[:,1], c='b', alpha=0.1)
        #scatter(mp[0], mp[1], c='r', s=100)
        #pause(0.1)

        #particles_out.append(mp[0])
        particles_out.append(hstack((mp,len(weights))))

        #if len(particles) <= 0.02 * n_particles:
        #    current_mean = particles.T.dot(weights)
        #    #resampled_particles = 0.1*randn(n_resampled, len(current_mean)) + current_mean
        #    resampled_particles = multivariate_normal(current_mean, diag([0.001, 0.001]), n_resampled)
        #    particles = vstack((particles, resampled_particles))
        #    cond = ((particles[:,0] >= 0) & (particles[:,1] >= 0) & (particles[:,0] <= 1) & (particles[:,1] <= 1) )
        #    particles = particles[cond]
        #if len(particles) < 10:
        #    return particles_out

    return array(particles_out)
