package com.onerdna.stalker;

interface IBinderService {
    String runCommand(in String command);
    void destroy();
}
